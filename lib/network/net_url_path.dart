class NetUrlPath {
  //environment url
  static String urlPrefix = "http://";

  static String testIp = "112.5.37.238";
  static String testPort = ":8010";
  static String testUrl = urlPrefix + testIp + testPort;

  static String produceIp = "112.5.37.69";
  static String producePort = ":8000";
  static String produceUrl = urlPrefix + produceIp + producePort;

  //Login
  static String login = "/api/v1/login/access-token"; //登录
}
