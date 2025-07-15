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

	nlb_name := atmos.Output(s.T(), options, "nlb.nlb_name")
	assert.True(s.T(), strings.HasPrefix(nlb_name, "eg-default-ue2-test-"))

	s.DriftTest(component, stack, nil)
}

func (s *ComponentSuite) TestAcm() {
	const component = "nlb/acm"
	const stack = "default-test"
	const awsRegion = "us-east-2"

	defer s.DestroyAtmosComponent(s.T(), component, stack, nil)
	options, _ := s.DeployAtmosComponent(s.T(), component, stack, nil)

	assert.NotNil(s.T(), options)

	nlb_name := atmos.Output(s.T(), options, "nlb.nlb_name")
	assert.True(s.T(), strings.HasPrefix(nlb_name, "eg-default-ue2-test-"))
}

func (s *ComponentSuite) TestDnsDelegated() {
	const component = "nlb/dns-delegated"
	const stack = "default-test"
	const awsRegion = "us-east-2"

	defer s.DestroyAtmosComponent(s.T(), component, stack, nil)
	options, _ := s.DeployAtmosComponent(s.T(), component, stack, nil)

	assert.NotNil(s.T(), options)

	nlb_name := atmos.Output(s.T(), options, "nlb.nlb_name")
	assert.True(s.T(), strings.HasPrefix(nlb_name, "eg-default-ue2-test-"))
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
