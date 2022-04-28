package networks_test

import (
	// "github.com/stretchr/testify/assert" 
	"os"
	"os/exec"
	"fmt"
	"github.com/tidwall/gjson"
	// "encoding/json"
	// "time"
	"testing"
	// "github.com/gruntwork-io/terratest/modules/terraform"
	// "github.com/gruntwork-io/terratest/modules/aws"
)
// var deployment_passed bool

func TestTerraformNetworks(t *testing.T){
	// terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
	// 	TerraformDir: "../",
	// })

	/******************** Init and Apply ********************/
	// terraform.InitAndApply(t, terraformOptions)


	// /********************************************************/
	// /*************** Store Terraform Outputs ****************/
	// /********************************************************/

	// fmt.Println("Testing begins")

	// ActualVpcJson 				:= terraform.OutputJson(t, terraformOptions, "vpc")
	// ActualPublicSubnet1Json 	:= terraform.OutputJson(t, terraformOptions, "public_subnet1")
	// ActualPublicSubnet2Json 	:= terraform.OutputJson(t, terraformOptions, "public_subnet2")
	// ActualPrivateSubnet2Json    := terraform.OutputJson(t, terraformOptions, "private_subnet2")
	// ActualPrivateSubnet1Json    := terraform.OutputJson(t, terraformOptions, "private_subnet1")
	// ActualSecretJson 			:= terraform.OutputJson(t, terraformOptions, "secret")
	// ActualSubnetGroupJson 		:= terraform.OutputJson(t, terraformOptions, "subnet_group")



	// /********************************************************/
	// /***************** Test Resource Tags ******************/
	// /********************************************************/

	// ActualVpcName := gjson.Get(ActualVpcJson, "tags.Name").String()
	// ExpectedVpcName := os.Getenv("TF_VAR_vpc_name") + "-" + os.Getenv("TF_VAR_environment")

	// if assert.Equal(t, ExpectedVpcName, ActualVpcName){
	// 	deployment_passed = true
	// 	t.Logf("PASS: The expected VPC name:%v matches the Actual VPC name:%v", ExpectedVpcName, ActualVpcName)
	// } else {
	// 	deployment_passed = false
	// 	terraform.Destroy(t, terraformOptions)
	// 	t.Fatalf("FAIL: Expected %v, but found %v", ExpectedVpcName, ActualVpcName)
	// }

	// /********************************************************/
	// /***************** Test Public Subnet 1 *****************/
	// /********************************************************/


	// ActualPublicSubnet1Name := gjson.Get(ActualPublicSubnet1Json, "tags.Name").String()
	// ExpectedPublicSubnet1Name := "wc_public_subnet_1" + "-" + os.Getenv("TF_VAR_environment")

	// if assert.Equal(t, ExpectedPublicSubnet1Name, ActualPublicSubnet1Name){
	// 	deployment_passed = true
	// 	t.Logf("PASS: The expected subnet name:%v matches the actual subnet name:%v", ExpectedPublicSubnet1Name, ActualPublicSubnet1Name)
	// } else {
	// 	deployment_passed = false
	// 	terraform.Destroy(t, terraformOptions)
	// 	t.Fatalf("FAIL: Expected %v, but found %v", ExpectedPublicSubnet1Name, ActualPublicSubnet1Name)
	// }

	// ActualPublicSubnet1Cluster 	 := gjson.Get(ActualPublicSubnet1Json, "tags.kubernetes\\.io/cluster/"+os.Getenv("TF_VAR_cluster_name")).String()
	// ExpectedPublicSubnet1Cluster := "shared"

	// if assert.Equal(t, ExpectedPublicSubnet1Cluster, ActualPublicSubnet1Cluster){
	// 	deployment_passed = true
	// 	t.Logf("PASS: The expected subnet cluster tag:%v matches the actual subnet cluster tag:%v", ExpectedPublicSubnet1Cluster, ActualPublicSubnet1Cluster)
	// } else {
	// 	deployment_passed = false
	// 	terraform.Destroy(t, terraformOptions)
	// 	t.Fatalf("FAIL: Expected %v, but found %v", ExpectedPublicSubnet1Cluster, ActualPublicSubnet1Cluster)
	// }

	// ActualPublicSubnet1Elb   	:= gjson.Get(ActualPublicSubnet1Json, "tags.kubernetes\\.io/role/elb").String()
	// ExpectedPublicSubnet1Elb 	:= "1"

	// if assert.Equal(t, ExpectedPublicSubnet1Elb, ActualPublicSubnet1Elb){
	// 	deployment_passed = true
	// 	t.Logf("PASS: The expected subnet cluster tag:%v matches the actual subnet cluster tag:%v", ExpectedPublicSubnet1Elb, ActualPublicSubnet1Elb)
	// } else {
	// 	deployment_passed = false
	// 	terraform.Destroy(t, terraformOptions)
	// 	t.Fatalf("FAIL: Expected %v, but found %v", ExpectedPublicSubnet1Elb, ActualPublicSubnet1Elb)
	// }

	// ActualPublicSubnet1MapPublicIp 	:= gjson.Get(ActualPublicSubnet1Json, "map_public_ip_on_launch").String()
	// ExpectedPublicSubnet1MapPublicIp 	:= "true"
	// if assert.Equal(t, ExpectedPublicSubnet1MapPublicIp, ActualPublicSubnet1MapPublicIp){
	// 	deployment_passed = true
	// 	t.Logf("PASS: expected map_public_ip:%v matches the actual map_public_ip:%v", ExpectedPublicSubnet1MapPublicIp, ActualPublicSubnet1MapPublicIp)
	// } else {
	// 	deployment_passed = false
	// 	terraform.Destroy(t, terraformOptions)
	// 	t.Fatalf("FAIL: Expected %v, but found %v", ExpectedPublicSubnet1MapPublicIp, ActualPublicSubnet1MapPublicIp)
	// }

	// /********************************************************/
	// /***************** Test Public Subnet 2 *****************/
	// /********************************************************/

	// ActualPublicSubnet2Name := gjson.Get(ActualPublicSubnet2Json, "tags.Name").String()
	// ExpectedPublicSubnet2Name := "wc_public_subnet_2" + "-" + os.Getenv("TF_VAR_environment")

	// if assert.Equal(t, ExpectedPublicSubnet2Name, ActualPublicSubnet2Name){
	// 	deployment_passed = true
	// 	t.Logf("PASS: The expected subnet name:%v matches the actual subnet name:%v", ExpectedPublicSubnet2Name, ActualPublicSubnet2Name)
	// } else {
	// 	deployment_passed = false
	// 	terraform.Destroy(t, terraformOptions)
	// 	t.Fatalf("FAIL: Expected %v, but found %v", ExpectedPublicSubnet2Name, ActualPublicSubnet2Name)
	// }

	// ActualPublicSubnet2Cluster 	 := gjson.Get(ActualPublicSubnet2Json, "tags.kubernetes\\.io/cluster/"+os.Getenv("TF_VAR_cluster_name")).String()
	// ExpectedPublicSubnet2Cluster := "shared"

	// if assert.Equal(t, ExpectedPublicSubnet2Cluster, ActualPublicSubnet2Cluster){
	// 	deployment_passed = true
	// 	t.Logf("PASS: The expected subnet cluster tag:%v matches the actual subnet cluster tag:%v", ExpectedPublicSubnet2Cluster, ActualPublicSubnet2Cluster)
	// } else {
	// 	deployment_passed = false
	// 	terraform.Destroy(t, terraformOptions)
	// 	t.Fatalf("FAIL: Expected %v, but found %v", ExpectedPublicSubnet2Cluster, ActualPublicSubnet2Cluster)
	// }

	// ActualPublicSubnet2Elb   	:= gjson.Get(ActualPublicSubnet2Json, "tags.kubernetes\\.io/role/elb").String()
	// ExpectedPublicSubnet2Elb 	:= "1"

	// if assert.Equal(t, ExpectedPublicSubnet2Elb, ActualPublicSubnet2Elb){
	// 	deployment_passed = true
	// 	t.Logf("PASS: The expected subnet cluster tag:%v matches the actual subnet cluster tag:%v", ExpectedPublicSubnet2Elb, ActualPublicSubnet2Elb)
	// } else {
	// 	deployment_passed = false
	// 	terraform.Destroy(t, terraformOptions)
	// 	t.Fatalf("FAIL: Expected %v, but found %v", ExpectedPublicSubnet2Elb, ActualPublicSubnet2Elb)
	// }

	// ActualPublicSubnet2MapPublicIp 	:= gjson.Get(ActualPublicSubnet2Json, "map_public_ip_on_launch").String()
	// ExpectedPublicSubnet2MapPublicIp 	:= "true"
	// if assert.Equal(t, ExpectedPublicSubnet2MapPublicIp, ActualPublicSubnet2MapPublicIp){
	// 	deployment_passed = true
	// 	t.Logf("PASS: expected map_public_ip:%v matches the actual map_public_ip:%v", ExpectedPublicSubnet2MapPublicIp, ActualPublicSubnet2MapPublicIp)
	// } else {
	// 	deployment_passed = false
	// 	terraform.Destroy(t, terraformOptions)
	// 	t.Fatalf("FAIL: Expected %v, but found %v", ExpectedPublicSubnet2MapPublicIp, ActualPublicSubnet2MapPublicIp)
	// }
	// /********************************************************/
	// /***************** Test Private Subnet 1 *****************/
	// /********************************************************/

	// ActualPrivateSubnet1Name   := gjson.Get(ActualPrivateSubnet1Json, "tags.Name").String()
	// ExpectedPrivateSubnet1Name := "wc_private_subnet_1" + "-" + os.Getenv("TF_VAR_environment")

	// if assert.Equal(t, ExpectedPrivateSubnet1Name, ActualPrivateSubnet1Name){
	// 	deployment_passed = true
	// 	t.Logf("PASS: The expected subnet name:%v matches the actual subnet name:%v", ExpectedPrivateSubnet1Name, ActualPrivateSubnet1Name)
	// } else {
	// 	deployment_passed = false
	// 	terraform.Destroy(t, terraformOptions)
	// 	t.Fatalf("FAIL: Expected %v, but found %v", ExpectedPrivateSubnet1Name, ActualPrivateSubnet1Name)
	// }

	// ActualPrivateSubnet1Cluster 	 := gjson.Get(ActualPrivateSubnet1Json, "tags.kubernetes\\.io/cluster/"+os.Getenv("TF_VAR_cluster_name")).String()
	// ExpectedPrivateSubnet1Cluster 	 := "shared"

	// if assert.Equal(t, ExpectedPrivateSubnet1Cluster, ActualPrivateSubnet1Cluster){
	// 	deployment_passed = true
	// 	t.Logf("PASS: The expected subnet cluster tag:%v matches the actual subnet cluster tag:%v", ExpectedPrivateSubnet1Cluster, ActualPrivateSubnet1Cluster)
	// } else {
	// 	deployment_passed = false
	// 	terraform.Destroy(t, terraformOptions)
	// 	t.Fatalf("FAIL: Expected %v, but found %v", ExpectedPrivateSubnet1Cluster, ActualPrivateSubnet1Cluster)
	// }

	// ActualPrivateSubnet1Elb   	:= gjson.Get(ActualPrivateSubnet1Json, "tags.kubernetes\\.io/role/internal-elb").String()
	// ExpectedPrivateSubnet1Elb 	:= "1"

	// if assert.Equal(t, ExpectedPrivateSubnet1Elb, ActualPrivateSubnet1Elb){
	// 	deployment_passed = true
	// 	t.Logf("PASS: The expected subnet cluster tag:%v matches the actual subnet cluster tag:%v", ExpectedPrivateSubnet1Elb, ActualPrivateSubnet1Elb)
	// } else {
	// 	deployment_passed = false
	// 	terraform.Destroy(t, terraformOptions)
	// 	t.Fatalf("FAIL: Expected %v, but found %v", ExpectedPrivateSubnet1Elb, ActualPrivateSubnet1Elb)
	// }

	
	// ActualPrivateSubnet1MapPublicIp 	:= gjson.Get(ActualPrivateSubnet1Json, "map_public_ip_on_launch").String()
	// ExpectedPrivateSubnet1MapPublicIp 	:= "false"
	// if assert.Equal(t, ExpectedPrivateSubnet1MapPublicIp, ActualPrivateSubnet1MapPublicIp){
	// 	deployment_passed = true
	// 	t.Logf("PASS: expected map_public_ip:%v matches the actual map_public_ip:%v", ExpectedPrivateSubnet1MapPublicIp, ActualPrivateSubnet1MapPublicIp)
	// } else {
	// 	deployment_passed = false
	// 	terraform.Destroy(t, terraformOptions)
	// 	t.Fatalf("FAIL: Expected %v, but found %v", ExpectedPrivateSubnet1MapPublicIp, ActualPrivateSubnet1MapPublicIp)
	// }

	// /********************************************************/
	// /***************** Test Private Subnet 2 ****************/
	// /********************************************************/

	// ActualPrivateSubnet2Name   := gjson.Get(ActualPrivateSubnet2Json, "tags.Name").String()
	// ExpectedPrivateSubnet2Name := "wc_private_subnet_2" + "-" + os.Getenv("TF_VAR_environment")

	// if assert.Equal(t, ExpectedPrivateSubnet2Name, ActualPrivateSubnet2Name){
	// 	deployment_passed = true
	// 	t.Logf("PASS: The expected subnet name:%v matches the actual subnet name:%v", ExpectedPrivateSubnet2Name, ActualPrivateSubnet2Name)
	// } else {
	// 	deployment_passed = false
	// 	terraform.Destroy(t, terraformOptions)
	// 	t.Fatalf("FAIL: Expected %v, but found %v", ExpectedPrivateSubnet2Name, ActualPrivateSubnet2Name)
	// }

	// ActualPrivateSubnet2Cluster 	 := gjson.Get(ActualPrivateSubnet2Json, "tags.kubernetes\\.io/cluster/"+os.Getenv("TF_VAR_cluster_name")).String()
	// ExpectedPrivateSubnet2Cluster 	 := "shared"

	// if assert.Equal(t, ExpectedPrivateSubnet2Cluster, ActualPrivateSubnet2Cluster){
	// 	deployment_passed = true
	// 	t.Logf("PASS: The expected subnet cluster tag:%v matches the actual subnet cluster tag:%v", ExpectedPrivateSubnet2Cluster, ActualPrivateSubnet2Cluster)
	// } else {
	// 	deployment_passed = false
	// 	terraform.Destroy(t, terraformOptions)
	// 	t.Fatalf("FAIL: Expected %v, but found %v", ExpectedPrivateSubnet2Cluster, ActualPrivateSubnet2Cluster)
	// }

	// ActualPrivateSubnet2Elb   	:= gjson.Get(ActualPrivateSubnet2Json, "tags.kubernetes\\.io/role/internal-elb").String()
	// ExpectedPrivateSubnet2Elb 	:= "1"

	// if assert.Equal(t, ExpectedPrivateSubnet2Elb, ActualPrivateSubnet2Elb){
	// 	deployment_passed = true
	// 	t.Logf("PASS: The expected subnet cluster tag:%v matches the actual subnet cluster tag:%v", ExpectedPrivateSubnet2Elb, ActualPrivateSubnet2Elb)
	// } else {
	// 	deployment_passed = false
	// 	terraform.Destroy(t, terraformOptions)
	// 	t.Fatalf("FAIL: Expected %v, but found %v", ExpectedPrivateSubnet2Elb, ActualPrivateSubnet2Elb)
	// }

	// ActualPrivateSubnet2MapPublicIp 	:= gjson.Get(ActualPrivateSubnet2Json, "map_public_ip_on_launch").String()
	// ExpectedPrivateSubnet2MapPublicIp 	:= "false"
	// if assert.Equal(t, ExpectedPrivateSubnet2MapPublicIp, ActualPrivateSubnet2MapPublicIp){
	// 	deployment_passed = true
	// 	t.Logf("PASS: expected map_public_ip:%v matches the actual map_public_ip:%v", ExpectedPrivateSubnet2MapPublicIp, ActualPrivateSubnet2MapPublicIp)
	// } else {
	// 	deployment_passed = false
	// 	terraform.Destroy(t, terraformOptions)
	// 	t.Fatalf("FAIL: Expected %v, but found %v", ExpectedPrivateSubnet2MapPublicIp, ActualPrivateSubnet2MapPublicIp)
	// }

	// /********************************************************/
	// /***************** Test Secrets Manager  ****************/
	// /********************************************************/


	// //Get the Secret ID
	// SecretId 			:= gjson.Get(ActualSecretJson, "id").String()

	// //Use the aws module to extract Secret as a json string
	// SecretText          := aws.GetSecretValue(t, os.Getenv("TF_VAR_region"), SecretId)

	// //Extract each Secret value from the json string
	// VpcIdInSecret			:= gjson.Get(SecretText, os.Getenv("TF_VAR_secrets_key_vpc_id")).String()
	// SubnetGroupIdInSecret 	:= gjson.Get(SecretText, os.Getenv("TF_VAR_secrets_key_subnet_group_id")).String()
	// PublicSubnetIdInSecret 	:= gjson.Get(SecretText, os.Getenv("TF_VAR_secrets_key_public_subnet_id")).String()

	// //Get actual values from resources
	// ActualVpcId				:= gjson.Get(ActualVpcJson, "id").String()
	// ActualSubnetGroupId		:= gjson.Get(ActualSubnetGroupJson, "id").String()
	// ActualPublicSubnetId1	:= gjson.Get(ActualPublicSubnet1Json, "id").String()
	// ActualPublicSubnetId2	:= gjson.Get(ActualPublicSubnet2Json, "id").String()

	// PublicSubnetMatchesSecret := false
	
	// //Check if the public subnet id secret matches the actual value for public subnet1 or public subnet2
	// if PublicSubnetIdInSecret == ActualPublicSubnetId1 || PublicSubnetIdInSecret == ActualPublicSubnetId2 {
	// 	PublicSubnetMatchesSecret = true
	// }
	// fmt.Println(PublicSubnetMatchesSecret)
	// if assert.Equal(t, true, PublicSubnetMatchesSecret){
	// 	deployment_passed = true
	// 	t.Logf("PASS: the public subnet id is stored in the secrets manager")
	// } else {
	// 	deployment_passed = false
	// 	terraform.Destroy(t, terraformOptions)
	// 	t.Fatalf("FAIL: the public subnet id in the secrets manager does not match either public subnet ids created")
	// }

	// //Check that the VPC id in the secret manager matches the VPC id
	// if assert.Equal(t, ActualVpcId, VpcIdInSecret){
	// 	deployment_passed = true
	// 	t.Logf("PASS: VPC Id:%v matches the actual VPC Id:%v", ActualVpcId, VpcIdInSecret)
	// } else {
	// 	deployment_passed = false
	// 	terraform.Destroy(t, terraformOptions)
	// 	t.Fatalf("FAIL: Expected %v, but found %v", ActualVpcId, VpcIdInSecret)
	// }

	// //Check that the private subnet group in the secret manager matches the actual
	// if assert.Equal(t, ActualSubnetGroupId, SubnetGroupIdInSecret){
	// 	deployment_passed = true
	// 	t.Logf("PASS: private subnet group id:%v matches the actual private subnet group id:%v", ActualSubnetGroupId, SubnetGroupIdInSecret)
	// } else {
	// 	deployment_passed = false
	// 	terraform.Destroy(t, terraformOptions)
	// 	t.Fatalf("FAIL: Expected %v, but found %v", ActualSubnetGroupId, SubnetGroupIdInSecret)
	// }

	/*******************************************************/
	/*************** Test Peering Connection ***************/
	/*******************************************************/

	PeeringRouteTableName := os.Getenv("TF_VAR_peering_rt_name")
    cmd := exec.Command("aws", "ec2", "describe-route-tables", "--filters", "Name=tag:Name,Values="+ PeeringRouteTableName, "--query", "RouteTables[].Routes[]")
    stdout, err := cmd.Output()

	fmt.Println("HHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHh")
	fmt.Println(string(stdout))
	
	Route := gjson.Get(string(stdout), "")
	fmt.Println(Route)
	
    if err != nil {
        fmt.Println(err.Error())
        return
    }

	// defer terraform.Destroy(t, terraformOptions)


}