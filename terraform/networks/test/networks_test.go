package networks_test

import (
	"github.com/stretchr/testify/assert" 
	"os"
	// "fmt"
	"github.com/tidwall/gjson"
	// "encoding/json"
	// "time"
	"testing"
	"github.com/gruntwork-io/terratest/modules/terraform"
	// "github.com/gruntwork-io/terratest/modules/aws"
)
var deployment_passed bool

func TestTerraformNetworks(t *testing.T){
	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: "../",
	})

	/********************************************************/
	/***************** Test Resource Tags ******************/
	/********************************************************/

	terraform.InitAndApply(t, terraformOptions)

	ActualVpcJson := terraform.OutputJson(t, terraformOptions, "vpc_name")

	ActualVpcName := gjson.Get(ActualVpcJson, "tags.Name").String()
	ExpectedVpcName := os.Getenv("TF_VAR_vpc_name") + "-" + os.Getenv("TF_VAR_environment")

	if assert.Equal(t, ExpectedVpcName, ActualVpcName){
		deployment_passed = true
		t.Logf("PASS: The expected VPC name:%v matches the Actual VPC name:%v", ExpectedVpcName, ActualVpcName)
	} else {
		deployment_passed = false
		terraform.Destroy(t, terraformOptions)
		t.Fatalf("FAIL: Expected %v, but found %v", ExpectedVpcName, ActualVpcName)
	}

	/********************************************************/
	/***************** Test Public Subnet 1 *****************/
	/********************************************************/

	ActualPublicSubnet1Json := terraform.OutputJson(t, terraformOptions, "public_subnet1")

	ActualPublicSubnet1Name := gjson.Get(ActualPublicSubnet1Json, "tags.Name").String()
	ExpectedPublicSubnet1Name := "wc_public_subnet_1" + "-" + os.Getenv("TF_VAR_environment")

	if assert.Equal(t, ExpectedPublicSubnet1Name, ActualPublicSubnet1Name){
		deployment_passed = true
		t.Logf("PASS: The expected subnet name:%v matches the actual subnet name:%v", ExpectedPublicSubnet1Name, ActualPublicSubnet1Name)
	} else {
		deployment_passed = false
		terraform.Destroy(t, terraformOptions)
		t.Fatalf("FAIL: Expected %v, but found %v", ExpectedPublicSubnet1Name, ActualPublicSubnet1Name)
	}

	ActualPublicSubnet1Cluster 	 := gjson.Get(ActualPublicSubnet1Json, "tags.kubernetes\\.io/cluster/"+os.Getenv("TF_VAR_cluster_name"))
	ExpectedPublicSubnet1Cluster := "shared"

	if assert.Equal(t, ExpectedPublicSubnet1Cluster, ActualPublicSubnet1Cluster){
		deployment_passed = true
		t.Logf("PASS: The expected subnet cluster tag:%v matches the actual subnet cluster tag:%v", ExpectedPublicSubnet1Cluster, ActualPublicSubnet1Cluster)
	} else {
		deployment_passed = false
		terraform.Destroy(t, terraformOptions)
		t.Fatalf("FAIL: Expected %v, but found %v", ExpectedPublicSubnet1Cluster, ActualPublicSubnet1Cluster)
	}

	ActualPublicSubnet1Elb   	:= gjson.Get(ActualPublicSubnet1Json, "tags.kubernetes\\.io/role/elb")
	ExpectedPublicSubnet1Elb 	:= 1

	if assert.Equal(t, ExpectedPublicSubnet1Elb, ActualPublicSubnet1Elb){
		deployment_passed = true
		t.Logf("PASS: The expected subnet cluster tag:%v matches the actual subnet cluster tag:%v", ExpectedPublicSubnet1Elb, ActualPublicSubnet1Elb)
	} else {
		deployment_passed = false
		terraform.Destroy(t, terraformOptions)
		t.Fatalf("FAIL: Expected %v, but found %v", ExpectedPublicSubnet1Elb, ActualPublicSubnet1Elb)
	}

	/********************************************************/
	/***************** Test Public Subnet 2 *****************/
	/********************************************************/

	ActualPublicSubnet2Json := terraform.OutputJson(t, terraformOptions, "public_subnet2")

	ActualPublicSubnet2Name := gjson.Get(ActualPublicSubnet2Json, "tags.Name").String()
	ExpectedPublicSubnet2Name := "wc_public_subnet_2" + "-" + os.Getenv("TF_VAR_environment")

	if assert.Equal(t, ExpectedPublicSubnet2Name, ActualPublicSubnet2Name){
		deployment_passed = true
		t.Logf("PASS: The expected subnet name:%v matches the actual subnet name:%v", ExpectedPublicSubnet2Name, ActualPublicSubnet2Name)
	} else {
		deployment_passed = false
		terraform.Destroy(t, terraformOptions)
		t.Fatalf("FAIL: Expected %v, but found %v", ExpectedPublicSubnet2Name, ActualPublicSubnet2Name)
	}

	ActualPublicSubnet2Cluster 	 := gjson.Get(ActualPublicSubnet2Json, "tags.kubernetes\\.io/cluster/"+os.Getenv("TF_VAR_cluster_name")).String()
	ExpectedPublicSubnet2Cluster := "shared"

	if assert.Equal(t, ExpectedPublicSubnet2Cluster, ActualPublicSubnet2Cluster){
		deployment_passed = true
		t.Logf("PASS: The expected subnet cluster tag:%v matches the actual subnet cluster tag:%v", ExpectedPublicSubnet2Cluster, ActualPublicSubnet2Cluster)
	} else {
		deployment_passed = false
		terraform.Destroy(t, terraformOptions)
		t.Fatalf("FAIL: Expected %v, but found %v", ExpectedPublicSubnet2Cluster, ActualPublicSubnet2Cluster)
	}

	ActualPublicSubnet2Elb   	:= gjson.Get(ActualPublicSubnet2Json, "tags.kubernetes\\.io/role/elb").String()
	ExpectedPublicSubnet2Elb 	:= 1

	if assert.Equal(t, ExpectedPublicSubnet2Elb, ActualPublicSubnet2Elb){
		deployment_passed = true
		t.Logf("PASS: The expected subnet cluster tag:%v matches the actual subnet cluster tag:%v", ExpectedPublicSubnet2Elb, ActualPublicSubnet2Elb)
	} else {
		deployment_passed = false
		terraform.Destroy(t, terraformOptions)
		t.Fatalf("FAIL: Expected %v, but found %v", ExpectedPublicSubnet2Elb, ActualPublicSubnet2Elb)
	}

	/********************************************************/
	/***************** Test Private Subnet 1 *****************/
	/********************************************************/

	ActualPrivateSubnet1Json   := terraform.OutputJson(t, terraformOptions, "private_subnet1")

	ActualPrivateSubnet1Name   := gjson.Get(ActualPrivateSubnet1Json, "tags.Name").String()
	ExpectedPrivateSubnet1Name := "wc_private_subnet_1" + "-" + os.Getenv("TF_VAR_environment")

	if assert.Equal(t, ExpectedPrivateSubnet1Name, ActualPrivateSubnet1Name){
		deployment_passed = true
		t.Logf("PASS: The expected subnet name:%v matches the actual subnet name:%v", ExpectedPrivateSubnet1Name, ActualPrivateSubnet1Name)
	} else {
		deployment_passed = false
		terraform.Destroy(t, terraformOptions)
		t.Fatalf("FAIL: Expected %v, but found %v", ExpectedPrivateSubnet1Name, ActualPrivateSubnet1Name)
	}

	ActualPrivateSubnet1Cluster 	 := gjson.Get(ActualPrivateSubnet1Json, "tags.kubernetes\\.io/cluster/"+os.Getenv("TF_VAR_cluster_name")).String()
	ExpectedPrivateSubnet1Cluster 	 := "shared"

	if assert.Equal(t, ExpectedPrivateSubnet1Cluster, ActualPrivateSubnet1Cluster){
		deployment_passed = true
		t.Logf("PASS: The expected subnet cluster tag:%v matches the actual subnet cluster tag:%v", ExpectedPrivateSubnet1Cluster, ActualPrivateSubnet1Cluster)
	} else {
		deployment_passed = false
		terraform.Destroy(t, terraformOptions)
		t.Fatalf("FAIL: Expected %v, but found %v", ExpectedPrivateSubnet1Cluster, ActualPrivateSubnet1Cluster)
	}

	ActualPrivateSubnet1Elb   	:= gjson.Get(ActualPrivateSubnet1Json, "tags.kubernetes\\.io/role/internal-elb").String()
	ExpectedPrivateSubnet1Elb 	:= 1

	if assert.Equal(t, ExpectedPrivateSubnet1Elb, ActualPrivateSubnet1Elb){
		deployment_passed = true
		t.Logf("PASS: The expected subnet cluster tag:%v matches the actual subnet cluster tag:%v", ExpectedPrivateSubnet1Elb, ActualPrivateSubnet1Elb)
	} else {
		deployment_passed = false
		terraform.Destroy(t, terraformOptions)
		t.Fatalf("FAIL: Expected %v, but found %v", ExpectedPrivateSubnet1Elb, ActualPrivateSubnet1Elb)
	}

	/********************************************************/
	/***************** Test Private Subnet 2 *****************/
	/********************************************************/

	ActualPrivateSubnet2Json   := terraform.OutputJson(t, terraformOptions, "private_subnet2")

	ActualPrivateSubnet2Name   := gjson.Get(ActualPrivateSubnet2Json, "tags.Name").String()
	ExpectedPrivateSubnet2Name := "wc_private_subnet_2" + "-" + os.Getenv("TF_VAR_environment")

	if assert.Equal(t, ExpectedPrivateSubnet2Name, ActualPrivateSubnet2Name){
		deployment_passed = true
		t.Logf("PASS: The expected subnet name:%v matches the actual subnet name:%v", ExpectedPrivateSubnet2Name, ActualPrivateSubnet2Name)
	} else {
		deployment_passed = false
		terraform.Destroy(t, terraformOptions)
		t.Fatalf("FAIL: Expected %v, but found %v", ExpectedPrivateSubnet2Name, ActualPrivateSubnet2Name)
	}

	ActualPrivateSubnet2Cluster 	 := gjson.Get(ActualPrivateSubnet2Json, "tags.kubernetes\\.io/cluster/"+os.Getenv("TF_VAR_cluster_name")).String()
	ExpectedPrivateSubnet2Cluster 	 := "shared"

	if assert.Equal(t, ExpectedPrivateSubnet2Cluster, ActualPrivateSubnet2Cluster){
		deployment_passed = true
		t.Logf("PASS: The expected subnet cluster tag:%v matches the actual subnet cluster tag:%v", ExpectedPrivateSubnet2Cluster, ActualPrivateSubnet2Cluster)
	} else {
		deployment_passed = false
		terraform.Destroy(t, terraformOptions)
		t.Fatalf("FAIL: Expected %v, but found %v", ExpectedPrivateSubnet2Cluster, ActualPrivateSubnet2Cluster)
	}

	ActualPrivateSubnet2Elb   	:= gjson.Get(ActualPrivateSubnet2Json, "tags.kubernetes\\.io/role/internal-elb").String()
	ExpectedPrivateSubnet2Elb 	:= 1

	if assert.Equal(t, ExpectedPrivateSubnet2Elb, ActualPrivateSubnet2Elb){
		deployment_passed = true
		t.Logf("PASS: The expected subnet cluster tag:%v matches the actual subnet cluster tag:%v", ExpectedPrivateSubnet2Elb, ActualPrivateSubnet2Elb)
	} else {
		deployment_passed = false
		terraform.Destroy(t, terraformOptions)
		t.Fatalf("FAIL: Expected %v, but found %v", ExpectedPrivateSubnet2Elb, ActualPrivateSubnet2Elb)
	}

	defer terraform.Destroy(t, terraformOptions)


}