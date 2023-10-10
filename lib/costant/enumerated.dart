/// 
/// #### 공연 데이터 타입
/// value:
///   - [ticket] = 예매
///   - [auction] = 경매
/// 
enum ShowDataType {
  ticket,
  auction
}

/// 
/// #### EndDrawer 콘텐츠 타입
/// value:
///   - [ticketing] = 예매
///   - [auction] = 경매
///   - [artist] = 아티스트
/// 
enum EndDrawerTicketContentType {
  ticketing,
  auction,
  artist
}

/// #### SVG Build 타입
/// value:
///   - [asset] = asset 폴더에서 데이터 로드
///   - [network] = network에서 이미지 주소로 로드
///   - [file] = 컴퓨터 로컬 파일
///   - [memory] = 메모리
///   - [string]
/// 
enum SVGType {
  asset,
  network,
  file,
  memory,
  string
}

/// #### Switch Build 타입
/// value:
///   - [material] = material 디자인 
///   - [cupertino] = cupertino 디자인
/// 
enum SwitchType {
  material,
  cupertino
}

/// #### 로그인 타입
/// value:
///   - [kakao] = 카카오 로그인 OR 회원가입
///   - [google] = 구글 로그인 OR 회원가입
///   - [apple] = 애플 로그인 OR 회원가입
///   - [naver] = 네이버 로그인 OR 회원가입
///   - [facebook] = 페이스북 로그인 OR 회원가입
///   - [email] = 이메일 로그인 OR 회원가입
/// 
enum LoginType {
  kakao,
  google,
  apple,
  naver,
  facebook,
  email
}

/// #### 선물방법 타입
/// value:
///   - [kakaoTalk] = 카카오톡으로 선물
///   - [sms] = SMS로 선물
/// 
enum GiftMethodType {
  kakaoTalk,
  sms,
}