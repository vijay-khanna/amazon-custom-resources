# stackDependency

A Lambda function which implements a Custom Resource for Cloud Formation that
gets output values from existing stacks.

## Installation

Create a Role with `./create-role.sh`. This creates a new stack with the
appropriate permissions for the function.

Deploy the lambda function with `./deploy-lambda.sh`. Now the function can be
used to get outputs from existing stacks via a Cloud Formation Custom Resource.

## Cloud Formation Usage

Use the function inside your Cloud Formation template by declaring a custom
resource, `Custom::StackDependency`.

The `Custom::StackDependency` refers to a `StackName` that is sent to the
Lambda function and is used to lookup the outputs from the selected stack. If
no stack is found `FAILED` is returned.

The outputs from the `Custom::StackDependency` can be referred with `Fn:GetAtt`.

Example: `"Fn::GetAtt": ["IamStack", "InstanceProfile"]`

In addition to the normal outputs from a stack, we also get access to all the
environment variables formatted as a Unix `env-file`. They are available with
the property `Environment`.

### Extended Example

```
"Parameters": {
  "IamRoleStack": {
    "Description": "Name of Iam role stack",
    "Type": "String"
  },
},
"Resources": {
  "IamStack": {
    "Type": "Custom::StackDependency",
    "Properties": {
      "ServiceToken": { "Fn::Join": [ "", [
        "arn:aws:lambda:",
        { "Ref": "AWS::Region" },
        ":",
        { "Ref": "AWS::AccountId" },
        ":function:stackDependency"
      ] ] },
      "StackName": { "Ref": "IamRoleStack" }
    }
  },
  "AppInstance": {
    "Type": "AWS::EC2::Instance",
    "Properties": {
      "IamInstanceProfile": {
        "Fn::GetAtt": ["IamStack", "InstanceProfile"]
      },
      "Metadata": {
        "AWS::CloudFormation::Init": {
          "config":{
            "files": {
              "/tmp/docker.env": {
                "content" :  { "Fn::Join" : ["", [
                  { "Fn::GetAtt": ["IamStack", "Environment"] },
                  "\n"
                ]]}
              }
            }
          }
        }
      }
    }
  }
}
```

