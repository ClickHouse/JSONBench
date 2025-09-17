Hologres is an all-in-one real-time data warehouse engine that is compatible with PostgreSQL. It supports online analytical processing (OLAP) and ad hoc analysis of PB-scale data. Hologres supports online data serving at high concurrency and low latency.

To evaluate the performance of Hologres, follow these guidelines to set up and execute the benchmark tests.

1. **Instance Purchase**:  
   Refer to the [Alibaba Cloud Hologres TPC-H Testing Documentation](https://www.alibabacloud.com/help/en/hologres/user-guide/test-plan?spm=a2c63.p38356.help-menu-113622.d_2_14_0_0.54e14f70oTAEXO) for details on purchasing Hologres and ECS instances. Both instances must be purchased within the same region and same zone.

2. **Benchmark Execution**:  
   Once the instances are set up, you need to prepare the following parameters:
   - `user`: user name for hologres, you can create users on Hologres web console
   - `password`: password for hologres, you can set this when create users
   - `host_name`: hostname of the Hologres instance, you can find this on Alibaba Cloud Console, you should select VPC network to achieve best performance
   - `port`: Port of the Hologres instance (usally '80')

   And then setup environments variables:
   ```
   export PG_USER={user};export PG_PASSWORD={password};export PG_HOSTNAME={host_name};export PG_PORT={port}
   ```

3. **Sample Execution**:
   ```bash
   ./main.sh 5 /root/bluesky
   ```
