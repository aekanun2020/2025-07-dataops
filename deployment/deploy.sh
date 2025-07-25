#!/bin/bash
#
# Deploy script for Loan ETL Pipeline
# This script is called by CI/CD after tests pass
#

set -e

# Configuration
DOCKER_IMAGE="thaibigdata/dataops-pipeline"
CONTAINER_NAME="loan-etl-pipeline"
DB_SERVER="34.16.100.219"
DB_DATABASE="TestDB"
DB_USERNAME="SA"

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${GREEN}=== Starting Deployment ===${NC}"
echo "Timestamp: $(date)"
echo "Image: ${DOCKER_IMAGE}:latest"

# Pull latest image
echo -e "${GREEN}Pulling latest image...${NC}"
docker pull ${DOCKER_IMAGE}:latest

# Stop and remove old container if exists
if [ "$(docker ps -aq -f name=${CONTAINER_NAME})" ]; then
    echo -e "${GREEN}Stopping old container...${NC}"
    docker stop ${CONTAINER_NAME} || true
    docker rm ${CONTAINER_NAME} || true
fi

# Run new container
echo -e "${GREEN}Starting new container...${NC}"
docker run -d \
    --name ${CONTAINER_NAME} \
    --restart unless-stopped \
    -e DB_SERVER=${DB_SERVER} \
    -e DB_DATABASE=${DB_DATABASE} \
    -e DB_USERNAME=${DB_USERNAME} \
    -e DB_PASSWORD="${DB_PASSWORD}" \
    -e DATA_URL="https://storage.googleapis.com/26jun2023/LoanStats_web.csv" \
    -v /var/log/loan-etl:/app/logs \
    ${DOCKER_IMAGE}:latest

# Check if container is running
sleep 5
if [ "$(docker ps -q -f name=${CONTAINER_NAME})" ]; then
    echo -e "${GREEN}✓ Deployment successful!${NC}"
    echo "Container ID: $(docker ps -q -f name=${CONTAINER_NAME})"
    
    # Setup cron job for daily run
    echo -e "${GREEN}Setting up daily schedule...${NC}"
    
    # Create cron script
    cat > /tmp/run-etl-daily.sh << 'EOF'
#!/bin/bash
docker restart loan-etl-pipeline
EOF
    
    chmod +x /tmp/run-etl-daily.sh
    sudo mv /tmp/run-etl-daily.sh /usr/local/bin/
    
    # Add to crontab (14:30 Bangkok time daily)
    (crontab -l 2>/dev/null | grep -v "run-etl-daily.sh" ; echo "30 14 * * * /usr/local/bin/run-etl-daily.sh >> /var/log/loan-etl/cron.log 2>&1") | crontab -
    
    echo -e "${GREEN}✓ Daily schedule set for 14:30 Asia/Bangkok${NC}"
else
    echo -e "${RED}✗ Deployment failed!${NC}"
    docker logs ${CONTAINER_NAME}
    exit 1
fi

echo -e "${GREEN}=== Deployment Complete ===${NC}"
