#!/bin/sh

aws eks --region $AWS_REGION update-kubeconfig --name $CLUSTER_NAME

DNS=$(bash -c 'kubectl get ingress utopia-ingress --output=jsonpath='{.status.loadBalancer.ingress[0].hostname}'')


aws route53 change-resource-record-sets --hosted-zone-id $HOSTED_ZONE --change-batch '
  {
      "Comment": "Testing creating a record set"
      ,"Changes": [{
        "Action"              : "DELETE"
        ,"ResourceRecordSet"  : {
          "Name"              : "'$RECORD_NAME'"
          ,"Type"             : "CNAME"
          ,"TTL"              : 120
          ,"ResourceRecords"  : [{
              "Value"         : "'$DNS'"
          }]
        }
      }]
    }
  '

kubectl delete ingress utopia-ingress
eksctl delete cluster $CLUSTER_NAME --region $AWS_REGION