---
title: Access Manager API Reference

language_tabs:
  - shell

toc_footers:
  - <a href='https://github.com/tripit/slate'>Documentation Powered by Slate</a>

includes:
  - errors

search: true
---

# <img src="images/StorageManager40px.png" style="float: left; margin-right: 5px"/> Access Manager (AM)

The Access Manager is a fork of FIWARE-Keypass and therefore has the same API.
Keypass is multi-tenant XACML server with PAP (Policy Administration Point) and
PDP (Policy Decision Point) capabilities.

Tenancy is defined by means of an HTTP header. Default configuration uses
`AM-Service` as the tenant header name, but it can be easily changed
modifying it in the config file.

The PDP endpoint will evaluate the Policies for the subjects contained in a
XACML request. This is a design decision took by Keypass in order to simplify
how the application is used.

You, as a developer, may wonder what a subject is, and why policies are grouped
around them. To simplify, a subject is the same you put in a `subject-id` in
an XACML request. You can then structure your user, groups and roles as usual
in your preferred Identity Management system, just taking into account that
those `ids` (subject, roles, groups) shall be used in your PEP when building
the XACML request.

Applying the policies per subject means that policies must be managed grouping
them by subject. Keypass PAP API is designed to accomplish this.

As XACML is an XML specification, Keypass API offers an XML Restful API.

From the PAP REST point of view, the only resource is the Policy, with resides
in a Subject of a Tenant. Both Tenant and Subject may be seen as namespaces, as
they are not resources _per se_.

# HTTP Headers

Since all following API calls make use of the  same headers, they are mentioned here once to avoid to mutch repetition.

## Tenant header

As already mentioned Keypass is a multi-tenant XACML server.
This allows one to use Keypass to store multiple policy sets for different uses cases.
With the certainty that the policy will not interfere with each other.

The tenants are identified by tenant header, which by default is `AM-Service`


```shell
curl https://am/pap/v1/subject/role12345
     -H "AM-Service: vlc"
```

### HTTP-Header 

`<TENANT-HEADER>: <tenant>`

### Header Parameters

Parameter     | Description
------------- | -----------
TENANT-HEADER | the configured tenant header string (default: `AM-Service`)
tenant        | the name of the tenant

## Content-Type header

Currently Keypass only supports the content type XML and which is also the default value when no content type was set.

```shell
curl https://am/pap/v1/subject/role12345
     -H "Content-type: application/xml"
```

### HTTP-Header 

`Content-type: application/xml`

# PAP API


## Create or update a policy

```shell
curl -X POST https://am/pap/v1/subject/role12345 -d @policy.xml
     -H "Content-type: application/xml"
     -H "tenantHeader: myTenant"
```

> the content of `policy.xml` is a XACML 3.0 policy like this

```xml
<?xml version="1.0"?>
<Policy xmlns="urn:oasis:names:tc:xacml:3.0:core:schema:wd-17" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="urn:oasis:names:tc:xacml:3.0:core:schema:wd-17 http://docs.oasis-open.org/xacml/3.0/xacml-core-v3-schema-wd-17.xsd" PolicyId="policy03" Version="1.0" RuleCombiningAlgId="urn:oasis:names:tc:xacml:3.0:rule-combining-algorithm:deny-unless-permit">
  <Target>
    <AnyOf>
      <AllOf>
        <Match MatchId="urn:oasis:names:tc:xacml:1.0:function:string-regexp-match">
          <AttributeValue DataType="http://www.w3.org/2001/XMLSchema#string">fiware:orion:.*</AttributeValue>
          <AttributeDesignator AttributeId="urn:oasis:names:tc:xacml:1.0:resource:resource-id" DataType="http://www.w3.org/2001/XMLSchema#string" MustBePresent="true" Category="urn:oasis:names:tc:xacml:3.0:attribute-category:resource"/>
        </Match>
      </AllOf>
    </AnyOf>
  </Target>
  <Rule RuleId="policy03rule01" Effect="Permit">
    <Condition>
      <Apply FunctionId="urn:oasis:names:tc:xacml:1.0:function:string-equal">
        <Apply FunctionId="urn:oasis:names:tc:xacml:1.0:function:string-one-and-only">
          <AttributeDesignator AttributeId="urn:oasis:names:tc:xacml:1.0:action:action-id" DataType="http://www.w3.org/2001/XMLSchema#string" MustBePresent="true" Category="urn:oasis:names:tc:xacml:3.0:attribute-category:action"/>
        </Apply>
        <AttributeValue DataType="http://www.w3.org/2001/XMLSchema#string">read</AttributeValue>
      </Apply>
    </Condition>
  </Rule>
</Policy>
```

> The above command returns the HTTP code Created (201) on success.

```HTTP
HTTP/1.1 201 Created
Location: http://am/pap/v1/subject/role12345/policy/policy03
```

Creates or updates a policy. Uses XACML `PolicyId` attribute as policy identifier, used
in other methods calls to retrieve or delete a single policy.

The given `PolicyId` is unique within the tenant. In case it already exists is
replaced (updated) with the new policy.

### HTTP Request

`POST /pap/v1/subject/:subjectId`

### URL Parameters

Parameter     | Description
------------- | -----------
subjectId     | the id of the subject

## Get a policy

```shell
curl https://am/pap/v1/subject/role12abc/policy/policy03
     -H "Content-type: application/xml"
     -H "Accept: application/xml"
     -H "tenantHeader: myTenant"
```
> The above command returns the HTTP code OK (200) on success.

```xml
<?xml version="1.0"?>
<Policy xmlns="urn:oasis:names:tc:xacml:3.0:core:schema:wd-17" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="urn:oasis:names:tc:xacml:3.0:core:schema:wd-17 http://docs.oasis-open.org/xacml/3.0/xacml-core-v3-schema-wd-17.xsd" PolicyId="policy03" Version="1.0" RuleCombiningAlgId="urn:oasis:names:tc:xacml:3.0:rule-combining-algorithm:deny-unless-permit">
  <Target>
    <AnyOf>
      <AllOf>
        <Match MatchId="urn:oasis:names:tc:xacml:1.0:function:string-regexp-match">
          <AttributeValue DataType="http://www.w3.org/2001/XMLSchema#string">fiware:orion:.*</AttributeValue>
          <AttributeDesignator AttributeId="urn:oasis:names:tc:xacml:1.0:resource:resource-id" DataType="http://www.w3.org/2001/XMLSchema#string" MustBePresent="true" Category="urn:oasis:names:tc:xacml:3.0:attribute-category:resource"/>
        </Match>
      </AllOf>
    </AnyOf>
  </Target>
  <Rule RuleId="policy03rule01" Effect="Permit">
    <Condition>
      <Apply FunctionId="urn:oasis:names:tc:xacml:1.0:function:string-equal">
        <Apply FunctionId="urn:oasis:names:tc:xacml:1.0:function:string-one-and-only">
          <AttributeDesignator AttributeId="urn:oasis:names:tc:xacml:1.0:action:action-id" DataType="http://www.w3.org/2001/XMLSchema#string" MustBePresent="true" Category="urn:oasis:names:tc:xacml:3.0:attribute-category:action"/>
        </Apply>
        <AttributeValue DataType="http://www.w3.org/2001/XMLSchema#string">read</AttributeValue>
      </Apply>
    </Condition>
  </Rule>
</Policy>
```

Retrieves an existing policy. Returns `404` if the policy does not exist. Please
note that `404` is returned also if the Tenant or Subject does not exists.

### HTTP Request

`GET /pap/v1/subject/:subjectId/policy/:policyId`

### URL Parameters

Parameter     | Description
------------- | -----------
subjectId     | the id of the subject 
policyId      | the id of the policy that should be returned

## Delete a policy

```shell
curl -X DELETE https://am/pap/v1/subject/subject_123/policy/policy03
     -H "Content-type: application/xml"
     -H "Accept: application/xml"
     -H "tenantHeader: myTenant"
```

> The above command returns the HTTP code OK (200) on success.

```xml
<?xml version="1.0"?>
<Policy xmlns="urn:oasis:names:tc:xacml:3.0:core:schema:wd-17" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="urn:oasis:names:tc:xacml:3.0:core:schema:wd-17     http://docs.oasis-open.org/xacml/3.0/xacml-core-v3-schema-wd-17.xsd" PolicyId="policy03" RuleCombiningAlgId="urn:oasis:names:tc:xacml:3.0:rule-combining-algorithm:deny-unless-permit" Version="1.0">
  <Target>
    <AnyOf>
      <AllOf>
        <Match MatchId="urn:oasis:names:tc:xacml:1.0:function:string-regexp-match">
          <AttributeValue DataType="http://www.w3.org/2001/XMLSchema#string">fiware:orion:.*</AttributeValue>
          <AttributeDesignator AttributeId="urn:oasis:names:tc:xacml:1.0:resource:resource-id" DataType="http://www.w3.org/2001/XMLSchema#string" MustBePresent="true" Category="urn:oasis:names:tc:xacml:3.0:attribute-category:resource"/>
        </Match>
      </AllOf>
    </AnyOf>
  </Target>
  <Rule RuleId="policy03rule01" Effect="Permit">
    <Condition>
      <Apply FunctionId="urn:oasis:names:tc:xacml:1.0:function:string-equal">
        <Apply FunctionId="urn:oasis:names:tc:xacml:1.0:function:string-one-and-only">
          <AttributeDesignator AttributeId="urn:oasis:names:tc:xacml:1.0:action:action-id" DataType="http://www.w3.org/2001/XMLSchema#string" MustBePresent="true" Category="urn:oasis:names:tc:xacml:3.0:attribute-category:action"/>
        </Apply>
        <AttributeValue DataType="http://www.w3.org/2001/XMLSchema#string">read</AttributeValue>
      </Apply>
    </Condition>
  </Rule>
</Policy>
```
Removes a policy. If removed successfully, returns the removed policy. In case
the policy does not exists, returns `404`.

### HTTP Request

` DELETE /pap/v1/subject/:subjectId/policy/:policyId `

### URL Parameters

Parameter     | Description
------------- | -----------
subjectId     | the id of the subject 
policyId      | the id of the policy that should be deleted

## Get subject policies

```shell
curl https://am/pap/v1/subject/role12345
     -H "Content-type: application/xml"
     -H "Accept: application/xml"
     -H "tenantHeader: myTenant"
```
> The command returns a PolicySet for the subject and the HTTP code OK (200). If the subject has no policies or the subject is none exsiting the PolicySet is empty.

```xml
<?xml version="1.0"?>
<PolicySet xmlns:ns0="urn:oasis:names:tc:xacml:3.0:core:schema:wd-17" xmlns:ns1="urn:oasis:names:tc:xacml:3.0:core:schema:wd-17" xmlns:ns2="urn:oasis:names:tc:xacml:3.0:core:schema:wd-17" xmlns="urn:oasis:names:tc:xacml:3.0:core:schema:wd-17" ns0:PolicyCombiningAlgId="urn:oasis:names:tc:xacml:3.0:rule-combining-algorithm:permit-overrides" ns1:PolicySetId="myTenant:role12345" ns2:Version="1.0">
  <Policy xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" PolicyId="policy03" RuleCombiningAlgId="urn:oasis:names:tc:xacml:3.0:rule-combining-algorithm:deny-unless-permit" Version="1.0" xsi:schemaLocation="urn:oasis:names:tc:xacml:3.0:core:schema:wd-17    http://docs.oasis-open.org/xacml/3.0/xacml-core-v3-schema-wd-17.xsd">
    <Target>
      <AnyOf>
        <AllOf>
          <Match MatchId="urn:oasis:names:tc:xacml:1.0:function:string-regexp-match">
            <AttributeValue DataType="http://www.w3.org/2001/XMLSchema#string">fiware:orion:.*</AttributeValue>
            <AttributeDesignator AttributeId="urn:oasis:names:tc:xacml:1.0:resource:resource-id" Category="urn:oasis:names:tc:xacml:3.0:attribute-category:resource" DataType="http://www.w3.org/2001/XMLSchema#string" MustBePresent="true"/>
          </Match>
        </AllOf>
      </AnyOf>
    </Target>
    <Rule Effect="Permit" RuleId="policy03rule01">
      <Condition>
        <Apply FunctionId="urn:oasis:names:tc:xacml:1.0:function:string-equal">
          <Apply FunctionId="urn:oasis:names:tc:xacml:1.0:function:string-one-and-only">
            <AttributeDesignator AttributeId="urn:oasis:names:tc:xacml:1.0:action:action-id" Category="urn:oasis:names:tc:xacml:3.0:attribute-category:action" DataType="http://www.w3.org/2001/XMLSchema#string" MustBePresent="true"/>
          </Apply>
          <AttributeValue DataType="http://www.w3.org/2001/XMLSchema#string">read</AttributeValue>
        </Apply>
      </Condition>
    </Rule>
  </Policy>
</PolicySet>
```

Retrieves all the policies of a given subject as a PolicySet element. If there
are no policies an empty policy set is returned. Please note that as stated in previous
sections, the tenant nor the subject are entities by themselves, so getting the
policies of non existent tenant or subject will return a valid PolicySet with no
policies.

### HTTP Request

` GET /pap/v1/subject/:subjectId `

### URL Parameters

Parameter     | Description
------------- | -----------
subjectId     | the id of the subject 

## Delete subject policies

```shell
curl -X DELETE https://am/pap/v1/subject/role12345
     -H "tenantHeader: myTenant"
```

> Will always return No Content (`204`) with an empty body

Convenience method to remove all the policies of the subject. Will return `204`
with an empty body, even for already empty or non-existent subjects (remember,
a subject is not a resource from the Keypass point of view).

### HTTP Request

` DELETE /pap/v1/subject/:subjectId `

### URL Parameters

Parameter     | Description
------------- | -----------
subjectId     | the id of the subject 

## Delete tenant policies

```shell
curl -X DELETE https://am/pap/v1
     -H "tenantHeader: myTenant"
```

> Will always return No Content (`204`) with an empty body

Convenience method to remove all the policies of the given tenant. As previous
method, returns `204` always.

### HTTP Request

` DELETE /pap/v1/ `

# PDP API

```shell
curl -X POST https://am/pdp/v3
     -H "Content-type: application/xml"
     -H "Accept: application/xml"
     -H "tenantHeader: myTenant"
     -d @request.xml
```

> The content of `request.xml` is a XACML 3.0 request like

```xml
<?xml version="1.0"?>
<Request xmlns="urn:oasis:names:tc:xacml:3.0:core:schema:wd-17" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="urn:oasis:names:tc:xacml:3.0:core:schema:wd-17 http://docs.oasis-open.org/xacml/3.0/xacml-core-v3-schema-wd-17.xsd" ReturnPolicyIdList="false" CombinedDecision="false">
  <Attributes Category="urn:oasis:names:tc:xacml:1.0:subject-category:access-subject">
    <Attribute IncludeInResult="false" AttributeId="urn:oasis:names:tc:xacml:1.0:subject:subject-id">
      <AttributeValue DataType="http://www.w3.org/2001/XMLSchema#string">role12345</AttributeValue>
    </Attribute>
  </Attributes>
  <Attributes Category="urn:oasis:names:tc:xacml:3.0:attribute-category:resource">
    <Attribute IncludeInResult="false" AttributeId="urn:oasis:names:tc:xacml:1.0:resource:resource-id">
      <AttributeValue DataType="http://www.w3.org/2001/XMLSchema#string">fiware:orion:tenant1234:us-west-1:res9876</AttributeValue>
    </Attribute>
  </Attributes>
  <Attributes Category="urn:oasis:names:tc:xacml:3.0:attribute-category:action">
    <Attribute IncludeInResult="false" AttributeId="urn:oasis:names:tc:xacml:1.0:action:action-id">
      <AttributeValue DataType="http://www.w3.org/2001/XMLSchema#string">read</AttributeValue>
    </Attribute>
  </Attributes>
</Request>
```

> The repsonce is a XACML 3.0 Response which hold the decision. For example

```xml
<Response xmlns="urn:oasis:names:tc:xacml:3.0:core:schema:wd-17">
  <Result>
    <Decision>NotApplicable</Decision>
    <Status>
      <StatusCode Value="urn:oasis:names:tc:xacml:1.0:status:ok"/>
    </Status>
  </Result>
</Response>
```

Evaluates the given request against the policies for the requests subjects. In
case the tenant or the subjects does not exists will return an XACML response
with Decision `NotApplicable`.

### HTTP Request

` POST /pdp/v3 `
