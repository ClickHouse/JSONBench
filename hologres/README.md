Hologres is an all-in-one real-time data warehouse engine that is compatible with PostgreSQL. It supports online analytical processing (OLAP) and ad hoc analysis of PB-scale data. Hologres supports online data serving at high concurrency and low latency.

To evaluate the performance of Hologres, follow these guidelines to set up and execute the benchmark tests.

### 1. Create an Alibaba Cloud Account and Provide Your UID  
Please first create an Alibaba Cloud account. After registration, kindly provide us with your **UID** (Account ID), which you can find by:  
- Clicking on your profile icon in the top-right corner → **Account Center** 
We will issue you an **Alibaba Cloud coupon** to support your testing, so please share your UID with us.

---

### 2. Purchase an Alibaba Cloud Hologres and ECS Instance  
Refer to the [Alibaba Cloud Hologres TPC-H Testing Documentation](https://www.alibabacloud.com/help/en/hologres/user-guide/test-plan?spm=a2c63.p38356.help-menu-113622.d_2_14_0_0.54e14f70oTAEXO) for details on purchasing Hologres and ECS instances. Both instances must be purchased within the same region and same zone.

#### 2.1 When creating the Hologres instance, please use the following configuration:

- **Region**: `China (Beijing)`  
  *(The new version is in gray-scale release in China (Beijing). Choosing this region ensures you can access the latest features)*
- **Specifications**: ✅ **Compute Group Type**  
- **Zone**: `Zone L`  
- **Gateway Nodes**: `2 Pieces`  
- **Reserved Computing Resources of Virtual Warehouse**: `32 CU`  
  *(This is the actual compute unit (CU) value used in the JSON result files.)*
- **Allocate to Initial Virtual Warehouse**: `Yes`
- **Enable Serverless Computing**: ✅ **True (Enabled)**  
- **Storage Redundancy Type**: `LRS `
- **VPC & vSwitch**:  
  - You need to **create a new VPC**.  
    - Region: `China (Beijing)`  
    - Name: Any name you prefer  
    - IPv4 CIDR Block: Select "Manually enter" and use one of the recommended values  
    - IPv6 CIDR Block: `Do Not Assign`  
  - During VPC creation, you’ll also create a **vSwitch**:  
    - Name: Any name  
    - Zone: `Beijing Zone L`  
    - IPv4 CIDR: Automatically filled based on VPC CIDR  
  > 💡 A **VPC (Virtual Private Cloud)** is a private network in the cloud. The **vSwitch** is a subnet within the VPC. We need both Hologres and ECS instances in the same VPC for fast internal communication.
- **Instance Name**: Choose any name
- **Service-linked Role**: Click **Create**

Once everything is configured and you’ve received the coupon, click **Buy Now** to proceed.

#### 2.2 When creating the ECS instance, please use the following configuration:
- **Billing Method**: `Pay-as-you-go` (you can release it after testing)
- **Region**: `China (Beijing)`
- **Network & Security Group**:  
  - VPC: Select the one you just created  
  - vSwitch: Automatically populated
- **Instance Type**:  
  - Series: `Compute Optimized c9i`  
  - Instance: `ecs.c9i.4xlarge` (16 vCPUs, 32 GiB RAM)  
  *(This is not performance-critical — it only runs the client script.)*
- **Image**:  
  - `Alibaba Cloud Linux` → `Alibaba Cloud Linux 3.2104 LTS 64-bit`  
- **System Disk**:  
  - Size: `2048 GiB`  
  - Performance: `PL3`  
  *(Larger and faster disk improves import speed since we’re loading ~70GB of TSV data. IO on the ECS can be a bottleneck.)*
- **Public IP Address**: ✅ Assign Public IPv4 Address
- **Management Settings**:  
  - Logon Credential: `Custom Password`  
  - Username: `root`  
  - Set a secure password

Click **Create Order** to launch the instance.

---

### 3. Connect to the ECS and Run the Benchmark  

After the ECS instance is ready:

1. SSH into the ECS instance.
2. Install Git and clone the repo:
   ```bash
   yum -y install git
   git clone https://github.com/ClickHouse/JSONBench.git
   cd JSONBench/hologres
   ```
3. Run the benchmark script:
   ```
    export PG_USER={AccessKeyID};export PG_PASSWORD={AccessKeySecret};export PG_HOSTNAME={Host};export PG_PORT={Port}
   ./main.sh 5 {your_bluesky_data_dir}
   ```

   - **AccessKeyID & AccessKeySecret**:  
     Go to the Alibaba Cloud Console → Profile Icon → **AccessKey** → Create one if needed.

     You can also create a hologres user (Click your instance to enter instance detail page -> click "Account Management"  -> "Create Custom User" -> Choose "Superuser") and use the username and password for PG_USER and PG_PASSWORD.
   - **Host & Port**:  
     In the Hologres console, click your instance ID → Copy the **VPC Endpoint** (e.g., `hgxxx-cn-beijing-vpc.hologres.aliyuncs.com:xxxx`).  
     - `Host` = domain without port (e.g., `hgxxx-cn-beijing-vpc.hologres.aliyuncs.com`)  
     - `Port` = the number after `:`

---

