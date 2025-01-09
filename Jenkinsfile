def remote=[:]
remote.name = 'vkt'
remote.host = '192.168.23.140'
remote.allowAnyHosts = true

def vm1=[:]
vm1.name = 'vm1'
vm1.allowAnyHosts = true

def vm2=[:]
vm2.name = 'vm2'
vm2.allowAnyHosts = true

def private_ip_1 = ''
def private_ip_2 = ''
def cert_arn = ''
def alb_arn = ''
def ConnectionStringToRDS = ''
pipeline {
  environment {
    PROVIDER_TF = credentials('provider-azure')
    dockerimagename = "ktei8htop15122004/savingaccountfe"
    dockerImage = ""
    DOCKERHUB_CREDENTIALS = credentials('dockerhub')
  }
  agent any 
  stages {
    stage('Check Agent') {
            steps {
                script {
                    echo "Running on agent: ${env.NODE_NAME}"
                }
            }
        }
    stage('Unit Test') {
      when {
        expression {
          return env.BRANCH_NAME != 'master';
        }
      }
      steps {
        sh 'terraform --version'
      }
    }
    stage('Test AWS') {
      steps {
       withCredentials([aws(accessKeyVariable: 'AWS_ACCESS_KEY_ID', credentialsId: 'aws-credential', secretKeyVariable: 'AWS_SECRET_ACCESS_KEY')]) {
          sh 'aws s3 ls'
        }
      }
    }
    
    stage('Create Resource Terraform in AWS'){
      steps{
       withCredentials([aws(accessKeyVariable: 'AWS_ACCESS_KEY_ID', credentialsId: 'aws-credential', secretKeyVariable: 'AWS_SECRET_ACCESS_KEY')]) {
          sh 'terraform init'
          sh "terraform plan -out main.tfplan"
          sh "terraform apply main.tfplan"
        }
      }
    }
     stage('Test Outputs') {
            steps {
                script {
                    def publicIpVm1 = sh(script: 'terraform output -raw public_ip_vm_1', returnStdout: true).trim()
                    def publicIpVm2 = sh(script: 'terraform output -raw public_ip_vm_2', returnStdout: true).trim()


                    echo "Public IP of VM 1: ${publicIpVm1}"
                    echo "Public IP of VM 2: ${publicIpVm2}"
                }
            }
        }
    stage('Test ansible') {
            steps {
               sh 'ansible --version'
            }
        }
    // stage('Build image') {
    //   steps {
    //     container('docker') {
    //       script {
    //         sh 'docker pull node:latest'
    //         sh 'docker pull nginx:stable-alpine'
    //         sh 'docker build --network=host -t ktei8htop15122004/savingaccountfe .'
    //       }
    //     }
    //   }
    // }

    // stage('Pushing Image') {
    //   steps {
    //     container('docker') {
    //       script {
    //         sh 'echo $DOCKERHUB_CREDENTIALS_PSW | docker login -u $DOCKERHUB_CREDENTIALS_USR --password-stdin'
    //         sh 'docker tag ktei8htop15122004/savingaccountfe ktei8htop15122004/savingaccountfe'
    //         sh 'docker push ktei8htop15122004/savingaccountfe:latest'
    //       }
    //     }
    //   }
    // }
    stage('Write acm-arn , alb-arn in master') {
    steps {
        script {
            vm1.user = 'ubuntu'
            vm1.password = '111111aA@'
            vm1.identityFile = '~/.ssh/id_rsa'
            vm1.host = sh(script: "terraform output -raw public_ip_vm_1", returnStdout: true).trim()
            cert_arn = sh(script: "terraform output -raw certificate_arn", returnStdout: true).trim()
            alb_arn = sh(script: "terraform output -raw alb_arn",returnStdout: true).trim()
        }
        sshCommand(remote: vm1, command: """
            sudo bash -c 
            echo ${cert_arn} > ~/cert_arn
            echo ${alb_arn} > ~/alb_arn
        """)
    }
}
//     stage('Install kubespray') {
//     steps {
//         script {
//             vm1.user = 'ubuntu'
//             vm1.identityFile = '~/.ssh/id_rsa'
//             vm1.password = '111111aA@'
//             vm1.host = sh(script: "terraform output -raw public_ip_vm_1", returnStdout: true).trim()
//             vm2.host = sh(script: "terraform output -raw public_ip_vm_2", returnStdout: true).trim()
//             private_ip_1 = sh(script: "terraform output -raw private_ip_address_vm_1", returnStdout: true).trim()
//             private_ip_2 = sh(script: "terraform output -raw private_ip_address_vm_2", returnStdout: true).trim()
//         }
//         sshCommand(remote: vm1, command: """
//                         sudo bash -c 
//                         if [ ! -d /home/ubuntu/kubespray ]; then
//                               echo "Cloning kubespray repository..."
//                               sudo apt update
//                               sudo apt install -y git python3 python3-pip
//                               git clone https://github.com/kubernetes-sigs/kubespray.git 
//                               pip3 install -r ~/kubespray/requirements.txt
//                               pip3 install --upgrade cryptography
//                               cp -r ~/kubespray/inventory/sample  ~/kubespray/inventory/mycluster             
//                               echo "
// # This inventory describe a HA typology with stacked etcd (== same nodes as control plane)
// # and 3 worker nodes
// # See https://docs.ansible.com/ansible/latest/inventory_guide/intro_inventory.html
// # for tips on building your # inventory

// # Configure 'ip' variable to bind kubernetes services on a different ip than the default iface
// # We should set etcd_member_name for etcd cluster. The node that are not etcd members do not need to set the value,
// # or can set the empty string value.
// [kube_control_plane]
// node1 ansible_host=${vm1.host}  ansible_ssh_private_key_file=~/.ssh/id_rsa ip=${private_ip_1} ansible_become=true ansible_become_user=root etcd_member_name=etcd1
// # node2 ansible_host=52.237.213.222  ansible_user=adminuser ansible_ssh_pass=111111aA@ ip=10.0.1.5 etcd_member_name=etcd2>
// # node3 ansible_host=95.54.0.14  # ip=10.3.0.3 etcd_member_name=etcd3

// [etcd:children]
// kube_control_plane

// [kube_node]
// node2 ansible_host=${vm2.host}  ansible_ssh_private_key_file=~/.ssh/id_rsa ansible_become=true ansible_become_user=root ip=${private_ip_2}
// # node4 ansible_host=95.54.0.15  # ip=10.3.0.4
// # node5 ansible_host=95.54.0.16  # ip=10.3.0.5
// # node6 ansible_host=95.54.0.17  # ip=10.3.0.6
//                               " > ~/kubespray/inventory/mycluster/inventory.ini

//                         else
//                               cp -r  ~/kubespray/inventory/sample  ~/kubespray/inventory/mycluster
//                               pip3 install -r ~/kubespray/requirements.txt
//                               pip3 install --upgrade cryptography
//                               echo "
// # This inventory describe a HA typology with stacked etcd (== same nodes as control plane)
// # and 3 worker nodes
// # See https://docs.ansible.com/ansible/latest/inventory_guide/intro_inventory.html
// # for tips on building your # inventory

// # Configure 'ip' variable to bind kubernetes services on a different ip than the default iface
// # We should set etcd_member_name for etcd cluster. The node that are not etcd members do not need to set the value,
// # or can set the empty string value.
// [kube_control_plane]
// node1 ansible_host=${vm1.host}  ansible_ssh_private_key_file=~/.ssh/id_rsa ip=${private_ip_1} ansible_become=true ansible_become_user=root etcd_member_name=etcd1
// # node2 ansible_host=52.237.213.222  ansible_ssh_private_key_file=~/.ssh/id_rsa ip=10.0.1.5 etcd_member_name=etcd2>
// # node3 ansible_host=95.54.0.14  # ip=10.3.0.3 etcd_member_name=etcd3

// [etcd:children]
// kube_control_plane

// [kube_node]
// node2 ansible_host=${vm2.host}  ansible_ssh_private_key_file=~/.ssh/id_rsa ansible_become=true ansible_become_user=root ip=${private_ip_2}
// # node4 ansible_host=95.54.0.15  # ip=10.3.0.4
// # node5 ansible_host=95.54.0.16  # ip=10.3.0.5
// # node6 ansible_host=95.54.0.17  # ip=10.3.0.6
//                               " > ~/kubespray/inventory/mycluster/inventory.ini
//                               echo "Kubespray directory already exists, skipping installation."
//                         fi
//         """)
//     }
// }

// stage('Install Ansible and playbook') {
//     steps {
//         script {
//             vm1.user = 'ubuntu'
//             vm1.identityFile = '~/.ssh/id_rsa'
//             vm1.password = '111111aA@'
//             vm1.host = sh(script: "terraform output -raw public_ip_vm_1", returnStdout: true).trim()
//             vm2.host = sh(script: "terraform output -raw public_ip_vm_2", returnStdout: true).trim()
//         }
//         sshCommand(remote: vm1, command: """
//             sudo bash -c
//             if [ ! -f /home/ubuntu/service.yaml ]; then
//                 set -e  # Exit on any error
//                 echo 'Updating package lists...'
//                 sudo apt update -y || { echo 'apt update failed!'; exit 1; }

//                 echo 'Installing software-properties-common...'
//                 sudo apt install -y software-properties-common || { echo 'apt install failed!'; exit 1; }

//                 echo 'Adding Ansible PPA...'
//                 sudo add-apt-repository ppa:ansible/ansible -y || { echo 'add-apt-repository failed!'; exit 1; }

//                 echo 'Updating package lists again...'
//                 sudo apt update -y || { echo 'Second apt update failed!'; exit 1; }

//                 echo 'Installing Ansible...'
//                 sudo apt install -y ansible || { echo 'apt install ansible failed!'; exit 1; }

//                 echo 'Checking Ansible version...'
//                 ansible --version || { echo 'ansible --version failed!'; exit 1; }

//                 echo 'Running kubespray playbook...'
//                 cd ~/kubespray
//                 ansible-playbook -i ~/kubespray/inventory/mycluster/inventory.ini --become --become-user=root cluster.yml || { echo 'ansible-playbook failed!'; exit 1; }
//             else 
//                 echo "Already running kubernetes"
//             fi
//             """)
        
//     }
// }

stage('Setup logstash configuration') {
    steps {
        script {
            vm1.user = 'ubuntu'
            vm1.identityFile = '~/.ssh/id_rsa'
            vm1.password = '111111aA@'
            vm1.host = sh(script: "terraform output -raw public_ip_vm_1", returnStdout: true).trim()
            vm2.host = sh(script: "terraform output -raw public_ip_vm_2", returnStdout: true).trim()
        }
        sshCommand(remote: vm1, command: """ 
            echo '
            input {
              tcp {
                port => 5000
                codec => plain
              }
            }
            
            output {
              elasticsearch {
                hosts => ["http://${vm1.host}:9200"]
                index => "express-logs-%{+yyyy.MM.dd}"
              }
              stdout { codec => rubydebug }
            }
            ' | sudo tee /home/ubuntu/logstash.conf > /dev/null
        """)
    }
}

stage('Install Docker and Docker Compose') {
            steps {
                script {
                     vm1.user = 'ubuntu'
                     vm1.identityFile = '~/.ssh/id_rsa'
                     vm1.password = '111111aA@'
                     vm1.host = sh(script: "terraform output -raw public_ip_vm_1", returnStdout: true).trim()
                     vm2.host = sh(script: "terraform output -raw public_ip_vm_2", returnStdout: true).trim()
                }
                sshCommand(remote: vm1, command: """ 
                    set -x
                    sudo apt-get update
                    sudo apt-get install -y \\
                        apt-transport-https \\
                        ca-certificates \\
                        curl \\
                        gnupg-agent \\
                        software-properties-common

                    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

                    sudo add-apt-repository \\
                       "deb [arch=amd64] https://download.docker.com/linux/ubuntu \\
                       \$(lsb_release -cs) \\
                       stable"

                    sudo apt-get update
                    sudo apt-get install -y docker-ce docker-ce-cli containerd.io

                    # Sửa URL bằng cách thêm 'v' trước số phiên bản
                    sudo curl -L "https://github.com/docker/compose/releases/download/v2.20.2/docker-compose-\$(uname -s)-\$(uname -m)" -o /usr/local/bin/docker-compose
                    sudo chmod +x /usr/local/bin/docker-compose

                    docker-compose --version
                """)
            }
        }
  stage('Add Docker-Compose file') {
      steps {
        script {
            vm1.user = 'ubuntu'
            vm1.identityFile = '~/.ssh/id_rsa'
            vm1.password = '111111aA@'
            vm1.host = sh(script: "terraform output -raw public_ip_vm_1", returnStdout: true).trim()
            vm2.host = sh(script: "terraform output -raw public_ip_vm_2", returnStdout: true).trim()
        }
        sshCommand(remote: vm1, command: """ 
            sudo bash -c 
            sudo touch /home/ubuntu/docker-compose.yml
            echo '
version: "3.8"

services:
  elasticsearch:
    image: docker.elastic.co/elasticsearch/elasticsearch:7.17.2
    container_name: elasticsearch-furnitureapp
    restart: always
    environment:
      - xpack.monitoring.enabled=true
      - xpack.watcher.enabled=false
      - "ES_JAVA_OPTS=-Xms512m -Xmx512m"
      - discovery.type=single-node
    ports:
      - "9200:9200"
    volumes:
      - elasticsearch_data:/usr/share/elasticsearch/data
    networks:
      - my_network

  logstash:
    image: docker.elastic.co/logstash/logstash:8.10.0
    container_name: logstash
    depends_on:
      - elasticsearch
    ports:
      - "5000:5000"
      - "5044:5044"
    volumes:
      - ./logstash.conf:/usr/share/logstash/pipeline/logstash.conf
    networks:
      - my_network

  kibana:
    container_name: kibana-furnitureapp
    image: docker.elastic.co/kibana/kibana:7.17.2
    environment:
      - ELASTICSEARCH_URL=http://elasticsearch:9200
    depends_on:
      - elasticsearch
    ports:
      - "5601:5601"
    networks:
      - my_network

  portainer:
    container_name: portainerio
    image: portainer/portainer-ce:latest
    ports:
      - "8000:8000"
      - "9999:9000"
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
      - portainer_data:/data
    restart: always
    networks:
      - my_network

  redisdb:
    container_name: redisdb
    image: redis:latest
    restart: always
    ports:
      - "6379:6379"
    networks:
      - my_network

  furnitureapp:
    container_name: furnitureapp
    image: ktei8htop15122004/furniture-app:latest
    ports:
      - "5002:5002"
    restart: always
    networks:
      - my_network
    depends_on:
      - redisdb
      - elasticsearch
      - logstash
      - kibana
    volumes:
      - ./nodejs-logs:/src/logs
  furnitureappadmin:
    container_name: furnitureappadmin
    image: ktei8htop15122004/furnitureapp-admin:latest
    ports:
      - "5001:5001"
    restart: always
    networks:
      - my_network
networks:
  my_network:
    driver: bridge

volumes:
  elasticsearch_data: {}
  portainer_data: {}

            ' > /home/ubuntu/docker-compose.yml
            """)
          }
        }
    stage('Deploying App to Kubernetes') {
      steps {
        script {
            vm1.user = 'ubuntu'
            vm1.identityFile = '~/.ssh/id_rsa'
            vm1.password = '111111aA@'
            vm1.host = sh(script: "terraform output -raw public_ip_vm_1", returnStdout: true).trim()
            vm2.host = sh(script: "terraform output -raw public_ip_vm_2", returnStdout: true).trim()
        }
        sshCommand(remote: vm1, command: """ 
            sudo docker compose up -d
            """)
          }
        }
    stage('Add healthcheck file to ALB to Kubernetes Cluster'){
      steps {
        script {
            vm1.user = 'ubuntu'
            vm1.identityFile = '~/.ssh/id_rsa'
            vm1.password = '111111aA@'
            vm1.host = sh(script: "terraform output -raw public_ip_vm_1", returnStdout: true).trim()
            vm2.host = sh(script: "terraform output -raw public_ip_vm_2", returnStdout: true).trim()
        }
        
          sshCommand(remote: vm1, command: """ 
            sudo bash -c "
            sudo mkdir -p /var/www/html
            sudo touch /var/www/html/healthz
            sudo echo 'Health Check OK' > /var/www/html/healthz
            "
            """)
        
      }
    }
    stage('Install Nginx Controller'){
       steps {
        script {
            vm1.user = 'ubuntu'
            vm1.identityFile = '~/.ssh/id_rsa'
            vm1.password = '111111aA@'
            vm1.host = sh(script: "terraform output -raw public_ip_vm_1", returnStdout: true).trim()
            vm2.host = sh(script: "terraform output -raw public_ip_vm_2", returnStdout: true).trim()
        }
      sshCommand(remote: vm1, command: """ 
            sudo apt update
            sudo apt install nginx -y
            sudo systemctl start nginx
            sudo systemctl enable nginx
            """)
       }
    }
    stage('Setup default page Nginx'){
       steps {
        script {
            vm1.user = 'ubuntu'
            vm1.identityFile = '~/.ssh/id_rsa'
            vm1.password = '111111aA@'
            vm1.host = sh(script: "terraform output -raw public_ip_vm_1", returnStdout: true).trim()
            vm2.host = sh(script: "terraform output -raw public_ip_vm_2", returnStdout: true).trim()
        }
      sshCommand(remote: vm1, command: """ 
            sudo bash -c 
            sudo chmod 666 /etc/nginx/sites-available/default
            sudo echo '
server {
    listen 80;

    location / {
        proxy_pass http://${vm1.host}:5002;
        proxy_connect_timeout 60s;
        proxy_read_timeout 60s;
        proxy_send_timeout 60s;
    }
    location /admin {
        proxy_pass http://${vm1.host}:5001;
        proxy_connect_timeout 60s;
        proxy_read_timeout 60s;
        proxy_send_timeout 60s;
    }

    location /healthz {
        root /var/www/html;
    }
}
            ' > /etc/nginx/sites-available/default
            sudo systemctl restart nginx
            """)
    }
    }
  }
}


