package networks_test

import (
	"github.com/stretchr/testify/assert" 
	"os"
	"fmt"
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


	ActualPublicSubnet1 	:= terraform.OutputJson(t, terraformOptions, "public_subnet1")
	fmt.Println("HEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEE")

	fmt.Println(ActualPublicSubnet1)
	// ActualPublicSubnet1Json := make(map[string]interface{})
	// json.Unmarshal([]byte(ActualPublicSubnet1), &ActualPublicSubnet1Json)
	// // ActualPublicSubnet1Name := ActualPublicSubnet1["tags"]["Name"]
	// // ExpectedPublicSubnet1Name := "wc_public_subnet_1-testing"
	// fmt.Println("HEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEE")
	// fmt.Println(ActualPublicSubnet1Json)
	// fmt.Println("HEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEE")

	// fmt.Println(ActualPublicSubnet1Json)
	// // fmt.Println(result["tags"]["Name"])

	// if assert.Equal(t, ExpectedPublicSubnet1Name, ActualPublicSubnet1Name){
	// 	deployment_passed = true
	// 	t.Logf("PASS: The expected VPC name:%v matches the Actual VPC name:%v", ExpectedPublicSubnet1Name, ActualPublicSubnet1Name)
	// } else {
	// 	deployment_passed = false
	// 	terraform.Destroy(t, terraformOptions)
	// 	t.Fatalf("FAIL: Expected %v, but found %v", ExpectedPublicSubnet1Name, ActualPublicSubnet1Name)
	// }


	defer terraform.Destroy(t, terraformOptions)


}