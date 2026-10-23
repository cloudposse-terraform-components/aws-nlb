package test

import (
	"strings"
	"testing"

	"github.com/cloudposse/test-helpers/pkg/atmos"
	helper "github.com/cloudposse/test-helpers/pkg/atmos/component-helper"
	"github.com/gruntwork-io/terratest/modules/random"
	"github.com/stretchr/testify/assert"
)

type ComponentSuite struct {
	helper.TestSuite
}

func (s *ComponentSuite) TestBasic() {
	const component = "nlb/basic"
	const stack = "default-test"
	const awsRegion = "us-east-2"

	defer s.DestroyAtmosComponent(s.T(), component, stack, nil)
	options, _ := s.DeployAtmosComponent(s.T(), component, stack, nil)
	assert.NotNil(s.T(), options)

	nlb := atmos.OutputMap(s.T(), options, "nlb")
	assert.True(s.T(), strings.HasPrefix(nlb["nlb_name"], "eg-default-ue2-test-"))

	s.DriftTest(component, stack, nil)
}

func (s *ComponentSuite) TestAcm() {
	const component = "nlb/acm"
	const stack = "default-test"
	const awsRegion = "us-east-2"

	defer s.DestroyAtmosComponent(s.T(), component, stack, nil)
	options, _ := s.DeployAtmosComponent(s.T(), component, stack, nil)

	assert.NotNil(s.T(), options)

	nlb := atmos.OutputMap(s.T(), options, "nlb")
	assert.True(s.T(), strings.HasPrefix(nlb["nlb_name"], "eg-default-ue2-test-"))
}

func (s *ComponentSuite) TestDnsDelegated() {
	const component = "nlb/dns-delegated"
	const stack = "default-test"
	const awsRegion = "us-east-2"

	defer s.DestroyAtmosComponent(s.T(), component, stack, nil)
	options, _ := s.DeployAtmosComponent(s.T(), component, stack, nil)

	assert.NotNil(s.T(), options)

	nlb := atmos.OutputMap(s.T(), options, "nlb")
	assert.True(s.T(), strings.HasPrefix(nlb["nlb_name"], "eg-default-ue2-test-"))
}

func (s *ComponentSuite) TestListeners() {
	const component = "nlb/listeners"
	const stack = "default-test"
	const awsRegion = "us-east-2"

	defer s.DestroyAtmosComponent(s.T(), component, stack, nil)
	options, _ := s.DeployAtmosComponent(s.T(), component, stack, nil)
	assert.NotNil(s.T(), options)

	nlb := atmos.OutputMap(s.T(), options, "nlb")
	assert.True(s.T(), strings.HasPrefix(nlb["nlb_name"], "eg-default-ue2-test-"))
	assert.NotEmpty(s.T(), nlb["security_group_id"])

	listeners := map[string]map[string]interface{}{}
	atmos.OutputStruct(s.T(), options, "listeners", &listeners)
	assert.Len(s.T(), listeners, 3)
	assert.EqualValues(s.T(), 1433, listeners["sql"]["port"])
	assert.Equal(s.T(), "TCP", listeners["sql"]["protocol"])
	assert.EqualValues(s.T(), 5022, listeners["sql-ag"]["port"])
	assert.Equal(s.T(), "UDP", listeners["avl"]["protocol"])
	assert.NotEmpty(s.T(), listeners["avl"]["target_group_arn"])

	s.DriftTest(component, stack, nil)
}

func (s *ComponentSuite) TestEnabledFlag() {
	const component = "nlb/disabled"
	const stack = "default-test"
	s.VerifyEnabledFlag(component, stack, nil)
}

func TestRunSuite(t *testing.T) {
	suite := new(ComponentSuite)
	suite.AddDependency(t, "vpc", "default-test", nil)
	subdomain := strings.ToLower(random.UniqueId())
	inputs := map[string]interface{}{
		"zone_config": []map[string]interface{}{
			{
				"subdomain": subdomain,
				"zone_name": "components.cptest.test-automation.app",
			},
		},
	}
	suite.AddDependency(t, "dns-delegated", "default-test", &inputs)
	suite.AddDependency(t, "acm", "default-test", nil)
	helper.Run(t, suite)
}
