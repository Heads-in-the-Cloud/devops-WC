package networks_test

import (
	"github.com/stretchr/testify/assert" 
	// "os"
	// "fmt"
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
	ExpectedVpcName := "wc-vpc-test"

	if assert.Equal(t, ExpectedVpcName, ActualVpcName){
		deployment_passed = true
		t.Logf("PASS: The expected VPC name:%v matches the Actual VPC name:%v", ExpectedVpcName, ActualVpcName)
	} else {
		deployment_passed = false
		terraform.Destroy(t, terraformOptions)
		t.Fatalf("FAIL: Expected %v, but found %v", ExpectedVpcName, ActualVpcName)
	}


	defer terraform.Destroy(t, terraformOptions)


}