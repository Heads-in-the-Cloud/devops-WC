package rds_test

import (
	"os"
	"time"
	"strings"
	"fmt"
	"testing"

	"github.com/tidwall/gjson"
	"github.com/stretchr/testify/assert"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/gruntwork-io/terratest/modules/aws"
	"github.com/gruntwork-io/terratest/modules/ssh"
	"github.com/gruntwork-io/terratest/modules/retry"

)
var deployment_passed bool

func TestTerraformNetworks(t *testing.T){

	//Create an SSH key pair for testing
	KeyPairName		:= os.Getenv("TF_VAR_key_name_test")
	KeyPair 		:= aws.CreateAndImportEC2KeyPair(t, os.Getenv("TF_VAR_region"), KeyPairName)

	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: "../",
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
	ExpectedKeyName := os.Getenv("TF_VAR_key_name_test")

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

	/********************************************************/
	/**************** Test Connection to RDS ****************/
	/********************************************************/

	fmt.Println("HHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHH")
	fmt.Println(KeyPair.KeyPair.PrivateKey)
	fmt.Println(KeyPair.KeyPair.PublicKey)
	terraformOptionsConnectionTesting := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		// The path to where our Terraform code is located
		TerraformDir: "./",

		// Variables to pass to our Terraform code using -var options
		Vars: map[string]interface{}{
			"aws_region":    os.Getenv("TF_VAR_region"),
			"instance_name": "terratest-instance",
			"instance_type": "t2.micro",
			"key_pair_name": os.Getenv("TF_VAR_key_name_test"),
			"db_host": ExpectedHost,
			"db_user": ExpectedUser,
			"db_password": ExpectedPassword,
		},
	})

	defer terraform.Destroy(t, terraformOptionsConnectionTesting)

	/******************** Init and Apply ********************/
	terraform.InitAndApply(t, terraformOptionsConnectionTesting)

	TestInstanceJson	:= terraform.OutputJson(t, terraformOptionsConnectionTesting, "instance")

	publicInstanceIP 	:= gjson.Get(TestInstanceJson, "public_ip").String()
	
	publicHost := ssh.Host{
		Hostname:    publicInstanceIP,
		SshKeyPair:  KeyPair.KeyPair,
		SshUserName: "ec2-user",
	}

	expectedText := fmt.Sprintf("ERROR 2003 (HY000): Can't connect to MySQL server on '%s' (110)", ExpectedHost)
	command 	 := fmt.Sprintf("mysql -h %s -u %s -p%s -D %s", ExpectedHost, ExpectedUser, ExpectedPassword,"utopia")

	RdsReachableFromOutsideVPC := true
	// maxRetries 					:= 10
	// timeBetweenRetries 			:= 2 * time.Second
	timeoutLimit				:= 200 * time.Second

	description 				:= fmt.Sprintf("SSH to public host %s", publicInstanceIP)

	//Wait for the instance to install MySQL
	time.Sleep(200 * time.Second)

	// Verify that we can SSH to the Instance and run commands
	// retry.DoWithRetryE(t, description, maxRetries, timeBetweenRetries, func() (string, error) {
	// 	actualText, err := ssh.CheckSshCommandE(t, publicHost, command)
	// 	fmt.Println(actualText)
		
		// if strings.TrimSpace(actualText) == expectedText {
		// 	RdsReachableFromOutsideVPC = false
			
	// 		t.Logf("Actual text matches expected text from command")
	// 		return "", retry.MaxRetriesExceeded{}
	// 	} else if err != nil {
	// 		fmt.Println(err)
	// 		return "", err
	// 	}
	// 	return "", nil
	// })


	/*************************************************************************/
	/******************** Try to Connect From Outside VPC ********************/
	/*************************************************************************/

	retry.DoWithTimeoutE(t, description, timeoutLimit, func() (string, error){
		actualText, err := ssh.CheckSshCommandE(t, publicHost, command)
		if strings.TrimSpace(actualText) == expectedText {
			RdsReachableFromOutsideVPC = false
		}
		fmt.Println(actualText)
		return actualText, err
	})

	if assert.Equal(t, false, RdsReachableFromOutsideVPC){
		deployment_passed = true
		t.Logf("PASS: the MySQL database is not accessible from a different VPC")
	} else {
		deployment_passed = false
		terraform.Destroy(t, terraformOptionsConnectionTesting)
		// terraform.Destroy(t, terraformOptions)
		t.Fatalf("FAIL: did not receieve the expected response when trying to connect to the MySQL database")
	}

	/*************************************************************************/
	/******************** Try to Connect From Within VPC *********************/
	/*************************************************************************/



	defer aws.DeleteEC2KeyPair(t, KeyPair)

	defer terraform.Destroy(t, terraformOptionsConnectionTesting)
	// defer terraform.Destroy(t, terraformOptions)

}
