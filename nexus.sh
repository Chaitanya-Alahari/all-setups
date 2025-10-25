#!/bin/bash

# Update system and install dependencies
sudo yum update -y
sudo yum install wget -y

# Install Java 17 (Corretto)
sudo yum install java-17-amazon-corretto-devel -y

# Verify Java installation
java -version

# Create application directory and navigate
sudo mkdir -p /app 
cd /app

# Clean up any previous installations
sudo rm -rf nexus-3.84.1-01 nexus sonatype-work nexus-3.84.1-01-linux-x86_64.tar.gz*

# Download and extract Nexus
sudo wget https://download.sonatype.com/nexus/3/nexus-3.84.1-01-linux-x86_64.tar.gz
sudo tar -xvf nexus-3.84.1-01-linux-x86_64.tar.gz

# Rename and organize directories properly
sudo mv nexus-3.84.1-01 nexus
sudo mkdir -p /app/sonatype-work

# Create nexus user if not exists
sudo id -u nexus &>/dev/null || sudo adduser nexus

# Set proper ownership
sudo chown -R nexus:nexus /app/nexus
sudo chown -R nexus:nexus /app/sonatype-work

# Configure nexus to run as nexus user
sudo sh -c 'echo "run_as_user=\"nexus\"" > /app/nexus/bin/nexus.rc'

# Configure Nexus VM options (adjust memory for t2.micro)
sudo -u nexus tee /app/nexus/bin/nexus.vmoptions > /dev/null << EOL
-Xms512m
-Xmx1024m
-XX:MaxDirectMemorySize=1024m
-XX:+UnlockDiagnosticVMOptions
-XX:+LogVMOutput
-XX:LogFile=../sonatype-work/nexus3/log/jvm.log
-XX:-OmitStackTraceInFastThrow
-Djava.net.preferIPv4Stack=true
-Dkaraf.data=../sonatype-work/nexus3
-Dkaraf.log=../sonatype-work/nexus3/log
-Djava.io.tmpdir=../sonatype-work/nexus3/tmp
-Dkaraf.etc=../nexus/etc
EOL

# Create systemd service file
sudo tee /etc/systemd/system/nexus.service > /dev/null << EOL
[Unit]
Description=Nexus Repository Manager
After=network.target

[Service]
Type=forking
LimitNOFILE=65536
User=nexus
Group=nexus
ExecStart=/app/nexus/bin/nexus start
ExecStop=/app/nexus/bin/nexus stop
Restart=on-abort
WorkingDirectory=/app/nexus
TimeoutStopSec=300

[Install]
WantedBy=multi-user.target
EOL

# Reload systemd and enable service
sudo systemctl daemon-reload
sudo systemctl enable nexus

# Configure security group (Amazon Linux 2 uses firewalld, but EC2 uses security groups)
# Make sure port 8081 is open in your EC2 security group

# Fix permissions one more time
sudo chown -R nexus:nexus /app/nexus
sudo chown -R nexus:nexus /app/sonatype-work

# Start Nexus
sudo systemctl start nexus

# Wait a moment and check status
sleep 5
sudo systemctl status nexus

# Display information
echo "Checking if Nexus is starting..."
echo "Initial admin password will be available at: /app/sonatype-work/nexus3/admin.password"
echo "Nexus will be accessible at: http://$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4):8081"

# Check if the file structure is correct
echo ""
echo "Checking directory structure:"
ls -la /app/
echo ""
echo "Nexus bin directory:"
ls -la /app/nexus/bin/ || echo "Nexus bin directory not found!"
