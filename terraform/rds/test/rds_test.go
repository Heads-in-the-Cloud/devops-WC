package rds_test

import (
	"github.com/stretchr/testify/assert" 
	"os"
	"fmt"
	"github.com/tidwall/gjson"
	"testing"
	"github.com/gruntwork-io/terratest/modules/terraform"
	// "github.com/gruntwork-io/terratest/modules/aws"
)
var deployment_passed bool

func TestTerraformNetworks(t *testing.T){
	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: "../",
		MigrateState: true,
	})

	/******************** Init and Apply ********************/
	terraform.InitAndApply(t, terraformOptions)


	/********************************************************/
	/*************** Store Terraform Outputs ****************/
	/********************************************************/

	fmt.Println("Testing begins")

	ActualBastionHostJson		 := terraform.OutputJson(t, terraformOptions, "bastion_host_instance")
	ActualSecretJson  			 := terraform.OutputJson(t, terraformOptions, "secrets")
	ActualRandomPasswordJson 	 := terraform.OutputJson(t, terraformOptions, "random_password")
	ActualRandomJwtKeyJson	 	 := terraform.OutputJson(t, terraformOptions, "random_jwt_key")
	ActualRdsJson				 := terraform.OutputJson(t, terraformOptions, "rds")

	/**************************************************/
	/*************** Test Bastion Host ****************/
	/**************************************************/

	//Check if the actual SSH key name matches the given one
	ActualKeyName 	:= gjson.Get(ActualBastionHostJson, "key_name").String()
	ExpectedKeyName := os.Getenv("TF_VAR_key_name")

	if assert.Equal(t, ExpectedKeyName, ActualKeyName){
		deployment_passed = true
		t.Logf("PASS: The expected key name:%v matches the actual key name:%v", ExpectedKeyName, ActualKeyName)
	} else {
		deployment_passed = false
		terraform.Destroy(t, terraformOptions)
		t.Fatalf("FAIL: Expected %v, but found %v", ExpectedKeyName, ActualKeyName)
	}

	/********************************************************/
	/***************** Test Secrets Manager  ****************/
	/********************************************************/


	//Get the Secret ID
	SecretId 			:= gjson.Get(ActualSecretJson, "id").String()

	//Use the aws module to extract Secret as a json string
	SecretText          := aws.GetSecretValue(t, os.Getenv("TF_VAR_region"), SecretId)

	//Extract each Secret value from the json string
	PasswordInSecret			:= gjson.Get(SecretText, os.Getenv("TF_VAR_secrets_key_password")).String()
	JwtKeyInSecret 				:= gjson.Get(SecretText, os.Getenv("TF_VAR_secrets_key_jwt_key")).String()
	DbUserInSecret 				:= gjson.Get(SecretText, os.Getenv("TF_VAR_secrets_key_user")).String()
	DbHostInSecret 				:= gjson.Get(SecretText, os.Getenv("TF_VAR_secrets_key_host")).String()

	//Get the expected values from the outputs
	ExpectedPassword			:= gjson.Get(ActualRandomPasswordJson, "result").String()
	ExpectedJwtKey				:= gjson.Get(ActualRandomJwtKeyJson, "result").String()
	ExpectedUser				:= gjson.Get(ActualRdsJson, "username").String()
	ExpectedHost				:= gjson.Get(ActualRdsJson, "address").String()

	if assert.Equal(t, ExpectedPassword, PasswordInSecret){
		deployment_passed = true
		t.Logf("PASS: The expected rds password:%v matches the actual rds password:%v", ExpectedPassword, PasswordInSecret)
	} else {
		deployment_passed = false
		terraform.Destroy(t, terraformOptions)
		t.Fatalf("FAIL: Expected %v, but found %v", ExpectedPassword, PasswordInSecret)
	}

	if assert.Equal(t, ExpectedJwtKey, JwtKeyInSecret){
		deployment_passed = true
		t.Logf("PASS: The expected jwt key:%v matches the actual jwt key:%v", ExpectedJwtKey, JwtKeyInSecret)
	} else {
		deployment_passed = false
		terraform.Destroy(t, terraformOptions)
		t.Fatalf("FAIL: Expected %v, but found %v", ExpectedJwtKey, JwtKeyInSecret)
	}

	if assert.Equal(t, ExpectedUser, DbUserInSecret){
		deployment_passed = true
		t.Logf("PASS: The expected rds user:%v matches the actual rds user:%v", ExpectedUser, DbUserInSecret)
	} else {
		deployment_passed = false
		terraform.Destroy(t, terraformOptions)
		t.Fatalf("FAIL: Expected %v, but found %v", ExpectedUser, DbUserInSecret)
	}

	if assert.Equal(t, ExpectedHost, DbHostInSecret){
		deployment_passed = true
		t.Logf("PASS: The expected rds host:%v matches the actual rds host:%v", ExpectedHost, DbHostInSecret)
	} else {
		deployment_passed = false
		terraform.Destroy(t, terraformOptions)
		t.Fatalf("FAIL: Expected %v, but found %v", ExpectedHost, DbHostInSecret)
	}
	defer terraform.Destroy(t, terraformOptions)


}