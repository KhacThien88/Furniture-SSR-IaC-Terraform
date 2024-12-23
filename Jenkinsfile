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
    stage('Install kubespray') {
    steps {
        script {
            vm1.user = 'ubuntu'
            vm1.identityFile = '~/.ssh/id_rsa'
            vm1.password = '111111aA@'
            vm1.host = sh(script: "terraform output -raw public_ip_vm_1", returnStdout: true).trim()
            vm2.host = sh(script: "terraform output -raw public_ip_vm_2", returnStdout: true).trim()
            private_ip_1 = sh(script: "terraform output -raw private_ip_address_vm_1", returnStdout: true).trim()
            private_ip_2 = sh(script: "terraform output -raw private_ip_address_vm_2", returnStdout: true).trim()
        }
        sshCommand(remote: vm1, command: """
                        sudo bash -c 
                        if [ ! -d ~/kubespray ]; then
                              echo "Cloning kubespray repository..."
                              sudo apt update
                              sudo apt install -y git python3 python3-pip
                              git clone https://github.com/kubernetes-sigs/kubespray.git 
                              pip3 install -r ~/kubespray/requirements.txt
                              pip3 install --upgrade cryptography
                              cp -r ~/kubespray/inventory/sample  ~/kubespray/inventory/mycluster             
                              echo "
# This inventory describe a HA typology with stacked etcd (== same nodes as control plane)
# and 3 worker nodes
# See https://docs.ansible.com/ansible/latest/inventory_guide/intro_inventory.html
# for tips on building your # inventory

# Configure 'ip' variable to bind kubernetes services on a different ip than the default iface
# We should set etcd_member_name for etcd cluster. The node that are not etcd members do not need to set the value,
# or can set the empty string value.
[kube_control_plane]
node1 ansible_host=${vm1.host}  ansible_ssh_private_key_file=~/.ssh/id_rsa ip=${private_ip_1} ansible_become=true ansible_become_user=root etcd_member_name=etcd1
# node2 ansible_host=52.237.213.222  ansible_user=adminuser ansible_ssh_pass=111111aA@ ip=10.0.1.5 etcd_member_name=etcd2>
# node3 ansible_host=95.54.0.14  # ip=10.3.0.3 etcd_member_name=etcd3

[etcd:children]
kube_control_plane

[kube_node]
node2 ansible_host=${vm2.host}  ansible_ssh_private_key_file=~/.ssh/id_rsa ansible_become=true ansible_become_user=root ip=${private_ip_2}
# node4 ansible_host=95.54.0.15  # ip=10.3.0.4
# node5 ansible_host=95.54.0.16  # ip=10.3.0.5
# node6 ansible_host=95.54.0.17  # ip=10.3.0.6
                              " > ~/kubespray/inventory/mycluster/inventory.ini

                        else
                              cp -r  ~/kubespray/inventory/sample  ~/kubespray/inventory/mycluster
                              pip3 install -r ~/kubespray/requirements.txt
                              pip3 install --upgrade cryptography
                              echo "
# This inventory describe a HA typology with stacked etcd (== same nodes as control plane)
# and 3 worker nodes
# See https://docs.ansible.com/ansible/latest/inventory_guide/intro_inventory.html
# for tips on building your # inventory

# Configure 'ip' variable to bind kubernetes services on a different ip than the default iface
# We should set etcd_member_name for etcd cluster. The node that are not etcd members do not need to set the value,
# or can set the empty string value.
[kube_control_plane]
node1 ansible_host=${vm1.host}  ansible_ssh_private_key_file=~/.ssh/id_rsa ip=${private_ip_1} ansible_become=true ansible_become_user=root etcd_member_name=etcd1
# node2 ansible_host=52.237.213.222  ansible_ssh_private_key_file=~/.ssh/id_rsa ip=10.0.1.5 etcd_member_name=etcd2>
# node3 ansible_host=95.54.0.14  # ip=10.3.0.3 etcd_member_name=etcd3

[etcd:children]
kube_control_plane

[kube_node]
node2 ansible_host=${vm2.host}  ansible_ssh_private_key_file=~/.ssh/id_rsa ansible_become=true ansible_become_user=root ip=${private_ip_2}
# node4 ansible_host=95.54.0.15  # ip=10.3.0.4
# node5 ansible_host=95.54.0.16  # ip=10.3.0.5
# node6 ansible_host=95.54.0.17  # ip=10.3.0.6
                              " > ~/kubespray/inventory/mycluster/inventory.ini
                              echo "Kubespray directory already exists, skipping installation."
                        fi
        """)
    }
}

stage('Install Ansible and playbook') {
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
                set -e  # Exit on any error
                echo 'Updating package lists...'
                sudo apt update -y || { echo 'apt update failed!'; exit 1; }

                echo 'Installing software-properties-common...'
                sudo apt install -y software-properties-common || { echo 'apt install failed!'; exit 1; }

                echo 'Adding Ansible PPA...'
                sudo add-apt-repository ppa:ansible/ansible -y || { echo 'add-apt-repository failed!'; exit 1; }

                echo 'Updating package lists again...'
                sudo apt update -y || { echo 'Second apt update failed!'; exit 1; }

                echo 'Installing Ansible...'
                sudo apt install -y ansible || { echo 'apt install ansible failed!'; exit 1; }

                echo 'Checking Ansible version...'
                ansible --version || { echo 'ansible --version failed!'; exit 1; }

                echo 'Running kubespray playbook...'
                cd ~/kubespray
                ansible-playbook -i ~/kubespray/inventory/mycluster/inventory.ini --become --become-user=root cluster.yml || { echo 'ansible-playbook failed!'; exit 1; }
            """)
        
    }
}

    stage('Create Deployment YAML') {
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
     kubectl create namespace devops-tools       
     echo "   
apiVersion: apps/v1
kind: Deployment
metadata:
  name: react-app-deployment
  labels:
    app: react-app
spec:
  replicas: 1
  selector:
    matchLabels:
      app: react-app
  template:
    metadata:
      labels:
        app: react-app
    spec:
      containers:
      - name: savingaccountfe
        image: ktei8htop15122004/savingaccountfe:latest
        ports:
        - containerPort: 80
        resources:
          requests:
            memory: "128Mi"
            cpu: "250m"
          limits:
            memory: "512Mi"
            cpu: "500m"
          " > ~/deployment.yaml
            """)
    }
      }


    stage('Create Service YAML') {
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
    echo "
apiVersion: v1
kind: Service
metadata:
  name: react-app-svc
spec:
  type: NodePort
  selector:
    app: react-app
  ports:
    - name: http
      port: 80
      targetPort: 80
      nodePort: 32100
      " > ~/service.yaml
      """
        )
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
            sudo kubectl apply -f ~/deployment.yaml
            sudo kubectl apply -f ~/service.yaml
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
            sudo bash -c 'echo "Health Check OK" > /var/www/html/healthz'
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
            sudo bash -c 
            sudo apt update
            sudo apt install nginx -y
            sudo systemctl start nginx
            sudo systemctl enable nginx
            sudo systemctl status nginx
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
            echo "
server {
    listen 80;

    location / {
        proxy_pass http://127.0.0.1:32100;
    }

    location /healthz {
        root /var/www/html;
    }
}
            " > /etc/nginx/sites-available/default
            sudo systemctl restart nginx
            """)
    }
    }
  }
}


