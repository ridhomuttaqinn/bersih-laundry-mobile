class ApiConfig {
  static const String baseUrl = String.fromEnvironment('API_BASE_URL',
      defaultValue: 'https://chem-promise-dogs-skirt.trycloudflare.com/api/v1');
  static const String testToken = String.fromEnvironment('DEPLOY_TEST_TOKEN');
}
