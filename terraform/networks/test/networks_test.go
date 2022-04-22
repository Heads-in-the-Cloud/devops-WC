package test

import (
	"fmt"
	"time"
	http_helper "github.com/gruntwork-io/terratest/modules/http-helper"
	"testing"
	"github.com/gruntwork-io/terratest/modules/terraform"
)

func TestTerraformNetworksExample(t *testing.T){
	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: "../"

		Vars: map[string]interface{}{
			"region": "us-west-2",
		},
	})

	terraform.InitAndApply(t, terraformOptions)

	defer terraform.Destroy(t, terraformOptions)

	publicIp := terraform.Output(t, terraformOptions, "public_up")

	url := fmt.Sprintf("http://%s:8080", publicIp)

	http_helper.HttpGetWithRetry(t, url, nil, 200, "I made a terraform module", 30, 5*time.Second)
}