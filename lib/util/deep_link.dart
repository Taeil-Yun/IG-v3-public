import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:ig-public_v3/costant/build_config.dart';

class DeepLinkBuilder {
  Future<String> getShortLink(String screenName, String id) async {
    String dynamicLinkPrefix =
        ig - publicBuildConfig.instance?.buildType == 'dev'
            ? 'https://deeplink.ig-public.biz'
            : 'https://a.ig-public.link/ig-publicappstore';

    final dynamicLinkParams = DynamicLinkParameters(
      uriPrefix: dynamicLinkPrefix,
      // link: Uri.parse('$dynamicLinkPrefix/$screenName?id=$id'),
      link: Uri.parse('$dynamicLinkPrefix/$screenName?id=$id'),
      androidParameters: AndroidParameters(
        packageName: ig - publicBuildConfig.instance?.buildType == 'dev'
            ? 'biz.ig-public.www'
            : 'com.ig-public.www',
      ),
      iosParameters: IOSParameters(
        bundleId: ig - publicBuildConfig.instance?.buildType == 'dev'
            ? 'biz.ig-public.www'
            : 'net.ig-public.www',
      ),
    );
    final dynamicLink =
        await FirebaseDynamicLinks.instance.buildShortLink(dynamicLinkParams);

    return dynamicLink.shortUrl.toString();
    // return '${dynamicLinkParams.link}';
  }

  Future<String> getShortLinkShare(
      String screenName, String id, String type) async {
    String dynamicLinkPrefix =
        ig - publicBuildConfig.instance?.buildType == 'dev'
            ? 'https://deeplink.ig-public.biz'
            : 'https://a.ig-public.link/ig-publicappstore';

    final dynamicLinkParams = DynamicLinkParameters(
      uriPrefix: dynamicLinkPrefix,
      // link: Uri.parse('$dynamicLinkPrefix/$screenName?id=$id'),
      link: Uri.parse('$dynamicLinkPrefix/$screenName?id=$id&type=$type'),
      androidParameters: AndroidParameters(
        packageName: ig - publicBuildConfig.instance?.buildType == 'dev'
            ? 'biz.ig-public.www'
            : 'com.ig-public.www',
      ),
      iosParameters: IOSParameters(
        bundleId: ig - publicBuildConfig.instance?.buildType == 'dev'
            ? 'biz.ig-public.www'
            : 'net.ig-public.www',
      ),
    );
    final dynamicLink =
        await FirebaseDynamicLinks.instance.buildShortLink(dynamicLinkParams);

    return dynamicLink.shortUrl.toString();
    // return '${dynamicLinkParams.link}';
  }
}
