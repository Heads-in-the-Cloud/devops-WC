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

func TestTerraformNetworksTags(t *testing.T){
	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: "../",
		// EnvVars: map[string]string{
		// 	"AWS_DEFAULT_REGION": ExpectedS3.Tags.Region,
		// },
	})

	terraform.InitAndApply(t, terraformOptions)

	ActualVpcName := terraform.Output(t, terraformOptions, "vpc_name")
	ExpectedVpcName := os.Getenv("TF_VAR_vpc_name") + "-" + os.Getenv("TF_VAR_environment")

	if assert.Equal(t, ExpectedVpcName, ActualVpcName){
		deployment_passed = true
		t.Logf("PASS: The expected VPC name:%v matches the Actual VPC name:%v", ExpectedVpcName, ActualVpcName)
	} else {
		deployment_passed = false
		terraform.Destroy(t, terraformOptions)
		t.Fatalf("FAIL: Expected %v, but found %v", ExpectedVpcName, ActualVpcName)
	}


	ActualPublicSubnet1Json := terraform.OutputJson(t, terraformOptions, "public_subnet1")

	ActualPublicSubnet1Name := gjson.Get(ActualPublicSubnet1Json, "tags.Name")
	ExpectedPublicSubnet1Name := "wc_public_subnet_1" + os.Getenv("TF_VAR_environment")

	if assert.Equal(t, ExpectedPublicSubnet1Name, ActualPublicSubnet1Name){
		deployment_passed = true
		t.Logf("PASS: The expected subnet name:%v matches the actual subnet name:%v", ExpectedPublicSubnet1Name, ActualPublicSubnet1Name)
	} else {
		deployment_passed = false
		terraform.Destroy(t, terraformOptions)
		t.Fatalf("FAIL: Expected %v, but found %v", ExpectedPublicSubnet1Name, ActualPublicSubnet1Name)
	}


	defer terraform.Destroy(t, terraformOptions)


}