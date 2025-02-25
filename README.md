# Azure_Webapp_ALB_TM_TF
Azure Solution for Web Application in different regions
# Architechture
![Solution architecture](https://github.com/user-attachments/assets/ffaaa2af-c5a7-4aa8-93df-4d56e4df7ee1)

# Scenario:

As a Cloud Administrator, your task is to deploy your company’s primary website across two Azure regions:
• Region 1: Canada Central
• Region 2: Ireland (North Europe)
Each region should have at least two servers running identical copies of the website to ensure redundancy and efficient load
balancing.

Requirements:
• Global Availability and Resilience:
  • The website must be accessible from anywhere in the world and resilient to failures.
  • Traffic routing should be based on the client’s proximity, directing requests to the closest region.
• Traffic Redirection:
  • Implement a solution to redirect traffic based on user location and proximity. Connection must be directed to the closest Region.
  • Load Balancing at each region 

# Solution:

Azure Application Gateway: support round robin method which ensures client's requests will be routed to different endpoints everytime
Azure Traffic Manager: ensure to redirect traffic based on user location and proximity to lowest network latency
