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

	ActualVpcJson := terraform.Output(t, terraformOptions, "vpc_name")

	ActualVpcName := gjson.Get(ActualVpcJson, "tags.Name")
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

	ActualPublicSubnet1Name := gjson.Get(ActualPublicSubnet1Json, "tags.Name")
	ExpectedPublicSubnet1Name := "wc_public_subnet_1" + "-" + os.Getenv("TF_VAR_environment")

	if assert.Equal(t, ExpectedPublicSubnet1Name, ActualPublicSubnet1Name){
		deployment_passed = true
		t.Logf("PASS: The expected subnet name:%v matches the actual subnet name:%v", ExpectedPublicSubnet1Name, ActualPublicSubnet1Name)
	} else {
		deployment_passed = false
		terraform.Destroy(t, terraformOptions)
		t.Fatalf("FAIL: Expected %v, but found %v", ExpectedPublicSubnet1Name, ActualPublicSubnet1Name)
	}

	ActualPublicSubnet1Cluster 	 := gjson.Get(ActualPublicSubnet1Json, "kubernetes.io/cluster/"+os.Getenv("TF_VAR_cluster_name"))
	ExpectedPublicSubnet1Cluster := "shared"

	if assert.Equal(t, ExpectedPublicSubnet1Cluster, ActualPublicSubnet1Cluster){
		deployment_passed = true
		t.Logf("PASS: The expected subnet cluster tag:%v matches the actual subnet cluster tag:%v", ExpectedPublicSubnet1Cluster, ActualPublicSubnet1Cluster)
	} else {
		deployment_passed = false
		terraform.Destroy(t, terraformOptions)
		t.Fatalf("FAIL: Expected %v, but found %v", ExpectedPublicSubnet1Cluster, ActualPublicSubnet1Cluster)
	}

	ActualPublicSubnet1Elb   	:= gjson.Get(ActualPublicSubnet1Json, "kubernetes.io/role/internal-elb")
	ExpectedPublicSubnet1Elb 	:= 1

	if assert.Equal(t, ExpectedPublicSubnet1Elb, ActualPublicSubnet1Elb){
		deployment_passed = true
		t.Logf("PASS: The expected subnet cluster tag:%v matches the actual subnet cluster tag:%v", ExpectedPublicSubnet1Elb, ActualPublicSubnet1Elb)
	} else {
		deployment_passed = false
		terraform.Destroy(t, terraformOptions)
		t.Fatalf("FAIL: Expected %v, but found %v", ExpectedPublicSubnet1Elb, ActualPublicSubnet1Elb)
	}


	defer terraform.Destroy(t, terraformOptions)


}