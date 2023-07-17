#!/bin/bash
#!/bin/bash

# Check if Hadoop is installed
if which hadoop >/dev/null 2>&1; then
    echo "Hadoop is installed."
else
    echo "Hadoop is not installed."
    exit 1
fi

#!/bin/bash

# Run the hadoop version command and extract the version string
version=$(hadoop version 2>&1 | grep "Hadoop" | awk '{print $2}')

# Print the extracted version
echo "Found Hadoop installation with version: $version"

# Stop and format Hadoop
stop-all.sh
hadoop namenode -format
start-all.sh

# Download and extract Hive
wget https://downloads.apache.org/hive/hive-3.1.2/apache-hive-3.1.2-bin.tar.gz
tar -xzf apache-hive-3.1.2-bin.tar.gz

export HIVE_HOME=~/apache-hive-3.1.2-bin
export PATH=$PATH:$HIVE_HOME/bin
export HADOOP_HOME=$HADOOP_HOME

# Set Hive environment variables in ~/.bashrc and update the current shell
echo "export HIVE_HOME=~/apache-hive-3.1.2-bin" >> ~/.bashrc
echo "export PATH=\$PATH:\$HIVE_HOME/bin" >> ~/.bashrc
source ~/.bashrc

# Add HADOOP_HOME to hive-config.sh and create necessary directories in HDFS
echo "export HADOOP_HOME=$HADOOP_HOME" >> ~/apache-hive-3.1.2-bin/bin/hive-config.sh
hdfs dfs -mkdir /tmp
hdfs dfs -chmod g+w /tmp
hdfs dfs -mkdir -p /user/hive/warehouse
hdfs dfs -chmod g+w /user/hive/warehouse

# Run the schematool command and redirect stderr to stdout
error=$(schematool -dbType derby -initSchema 2>&1)
result=$?
if [[ $result -ne 0 ]]; then
    echo "Error: Initialization of schema failed with exit code $result"
    echo "Error message: $error"
    if [[ $error == *"NUCLEUS_ASCII"* ]]; then
        mv metastore_db metastore_db.tmp
        schematool -dbType derby -initSchema
    else
        exit 1
    fi
fi


echo "Please open a new terminal and check your hive installation "
