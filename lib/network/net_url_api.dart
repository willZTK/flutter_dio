import 'net_manager.dart';
import 'net_url_path.dart';

class Api {
  /*
  登录
  username: 用户手机号，必传
  password: 手机验证码，必传
  */
  static login(Map params) {
    return NetManager.getInstance().request(
      NetUrlPath.login,
      data: params,
      contentType: DioContentType.x_www_form_urlencoded,
      withLoading: true,
    );
  }
}
