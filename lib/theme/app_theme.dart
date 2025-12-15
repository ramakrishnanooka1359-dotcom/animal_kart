import 'package:animal_kart_demo2/utils/app_colors.dart';
import 'package:animal_kart_demo2/utils/app_constants.dart';
import 'package:flutter/material.dart';

// New Color Palette
const Color akForestWhisper = Color(0xFF238E8B);
const Color akElectricLime = Color(0xFFE7EE57);
const Color akSageStone = Color(0xFF4C7570);
const Color akPureCanvas = Color(0xFFF4F4F4);
const Color akSunsetBurst = Color(0xFFF85B37);
const Color akMintBreeze = Color(0xFFB9DBBF);
const Color akCharcoalShadow = Color(0xFF232828);

extension CustomThemeExt on ThemeData {
  bool get isLightTheme => (brightness == Brightness.light);
  Color get whiteColor => isLightTheme ? akWhiteColor : akBlackColor;
  Color get alterWhite =>
      isLightTheme ? akWhiteColor : akDarkThemeBackgroundColor;

  // Color get secondaryButtonColor =>
  //     isLightTheme ? nfRedColorAccent : Colors.lightGreen;

  //button colors
  Color get mainThemeColor =>
      isLightTheme ? kPrimaryLightColor : akDarkThemeBackgroundColor;
  Color get mainThemeBgColor =>
      isLightTheme ? akWhiteColor : akDarkThemeBackgroundColor;
  Color get inActiveButtonColor =>
      isLightTheme ? akInactiveButtonLightColor : akInactiveButtonDarkColor;
  Color get cancelButtonBackgroundColor =>
      isLightTheme ? akWhiteColor : akDarkThemeBackgroundColor;

  Color get borderColor =>
      isLightTheme ? akBorderLightColor : akBorderDarkColor;
  Color get tableHeaderColor =>
      isLightTheme ? akTableHeaderLightColor : akTableHeaderDarkColor;
  Color get tablerowColor =>
      isLightTheme ? akTableRowLightColor : akTableRowDarkColor;
  Color get tableBorderColor =>
      isLightTheme ? akTableBorderLightColor : akTableBorderDarkColor;

  //text color
  Color get primaryTextColor => isLightTheme ? akBlackColor : akWhiteColor;
  Color get secondaryTextColor => isLightTheme ? akLightText : akWhiteColor54;
  Color get reversePrimaryTextColor =>
      isLightTheme ? akWhiteColor : akBlackColor;

  Color get subTotalsTextColor =>
      isLightTheme ? akSubTotalsLightColor : akSubTotalsDarkColor;
  Color get hintTextColor =>
      isLightTheme ? akHintTextLightColor : akHintTextDarkColor;
  //shimmerColors
  Color get shimmerBaseColor =>
      isLightTheme ? akShimmerBaseLightColor : akShimmerBaseDarkColor;
  Color get shimmerhighlightColor =>
      isLightTheme ? akShimmerHighlightLightColor : akShimmerHighlightDarkColor;

  //shadow Color

  // Color get dialogShadowColor => isLightTheme ? nfBlackColor54 : nfWhiteColor54;
  Color? get dialogBackgroundColorX =>
      isLightTheme ? null : akDialogBackgroundColor;
  Color get popUpColor =>
      isLightTheme ? akWhiteColor : akDarkThemeBackgroundColor;

  //disabled colors
  Color get akTextDisabledColor =>
      isLightTheme ? akTableHeaderLightColor : akTableHeaderDarkColor;
  Color get akTextDisabledBorderColor =>
      isLightTheme ? akDisabledBorderLightColor : akDisabledBorderDarkColor;
  Color get akTextEnabledBorderColor =>
      isLightTheme ? akEnabledBorderLightColor : akEnabledBorderDarkColor;

  //Colors
  Color get kAkRed => isLightTheme ? akRedColor : akRedColor;
  Color get kAkGreen => isLightTheme ? akGreenColor : akGreenColor;

  Color get tileRedColor =>
      isLightTheme ? tileRedLightColor.withOpacity(0.36) : tileRedLightColor;
  Color get tileGreenColor => isLightTheme
      ? tileGreenLightColor.withOpacity(0.36)
      : tileGreenLightColor;
  Color get tileOrangeColor => isLightTheme
      ? akOrangeColorAccent.withOpacity(0.36)
      : akOrangeColorAccent;

  Color get lightThemeCardColor => isLightTheme ? kCardBg : akTableRowDarkColor;

  Color get lightBlueSelectedTileColor => isLightTheme
      ? akLightBlueSelectedTileLightColor
      : akLightBlueSelectedTileDarkColor;
  Color get tileGreyishBlueColor =>
      isLightTheme ? akTileGreyishBlueLightColor : akTileGreyishBlueLightColor;
  Color get tileLightOrangeColor => isLightTheme
      ? akTileOrangeLightColor.withOpacity(0.16)
      : akTileOrangeLightColor.withOpacity(0.46);
  Color get akColor12 => isLightTheme ? akBlackColor12 : akWhiteColor24;
}

//Light Theme Colors
const Color kPrimaryLightColor = akForestWhisper;
const Color akInactiveButtonLightColor = Color(0xff97b9d1);
const Color akBorderLightColor = Color(0xFFD7E2EB);
const Color akTableHeaderLightColor = Color(0xFFF3F3F3);
const Color akTableRowLightColor = Color(0xFFF0F0F0);
const Color akTableBorderLightColor = Color(0xFFbccbd6);
const Color akDisabledBorderLightColor = Color(0xFFD7E2EB);
const Color akEnabledBorderLightColor = Color(0xFFB5C5D2);
const Color akSubTotalsLightColor = Color(0xFF707B87);
const Color akHintTextLightColor = Colors.grey;
Color akShimmerBaseLightColor = Colors.grey.shade300;
Color akShimmerHighlightLightColor = Colors.grey.shade100;
const Color akLightBlueCardLightColor = Color(0xffd2e8ff);
const Color akLightBlueSelectedTileLightColor = Color(0xFFF0F8FF);
// const Color nfTextColor = nfBlackColor87;
const Color tileRedLightColor = Color(0xFFE44E56);
const Color tileGreenLightColor = Color(0XFF1A873C);
const Color akTileGreyishBlueLightColor = Color(0XFFD5E2EC);
const Color akTileOrangeLightColor = Color(0XFFE66811);
const Color akAlertRedColor = Color(0XFFC71720);
const Color akAlertGreenColor = Color(0XFF1A873C);

// #E66811 · 16%

//Dark Theme Colors
const Color akDarkThemeBackgroundColor = akCharcoalShadow;
const Color kPrimaryDarkColor = akForestWhisper;
const Color akInactiveButtonDarkColor = Color.fromARGB(255, 161, 188, 206);
const Color akBorderDarkColor = akWhiteColor12;
const Color akTableHeaderDarkColor = Color(0xFF5A5E63);
const Color akTableRowDarkColor = Color(0XFF84858c);
const Color akTableBorderDarkColor = Color(0XFF242c2c);
const Color akDisabledBorderDarkColor = Color(0XFF8c8c8c);
const Color akEnabledBorderDarkColor = Color(0xFFB5C5D2);
const Color akDialogBackgroundColor = Color(0XFF393c3c);
const Color akSubTotalsDarkColor = akWhiteColor60;
const Color akHintTextDarkColor = akWhiteColor54;
const Color akShimmerBaseDarkColor = akWhiteColor12;
const Color akShimmerHighlightDarkColor = akWhiteColor38;
const Color akLightBlueCardDarkColor = Color(0xFF00162d);
const Color akLightBlueSelectedTileDarkColor = Color(0xFF004480);

//Black shadeColors
const Color akBlackColor = Colors.black;
const Color akBlackColor12 = Colors.black12;
const Color akBlackColor26 = Colors.black26;
const Color akBlackColor38 = Colors.black38;
const Color akBlackColor45 = Colors.black45;
const Color akBlackColor54 = Colors.black54;
const Color akLightText = Color(0xff929FA9);
const Color akBlackColor87 = Colors.black87;

// White
const Color akWhiteColor = Colors.white;
const Color akWhiteColor10 = Colors.white10;
const Color akWhiteColor12 = Colors.white12;
const Color akWhiteColor24 = Colors.white24;
const Color akWhiteColor30 = Colors.white30;
const Color akWhiteColor38 = Colors.white38;
const Color akWhiteColor54 = Colors.white54;
const Color akWhiteColor60 = Colors.white60;
const Color akWhiteColor70 = Colors.white70;

//red color
const MaterialColor akRedColor = Colors.red;
const MaterialAccentColor akRedAccentColor = Colors.redAccent;
const Color akRejectedRedColor = Color(0XFFC71720);
//green color shades
const MaterialColor akGreenColor = Colors.green;
const Color akCheckGreenColor = Color(0XFF1A873C);

//blue color shades
const MaterialColor akBlueColor = Colors.blue;
const MaterialColor akBlueColorGrey = Colors.blueGrey;
const MaterialAccentColor akBlueColorAccent = Colors.blueAccent;
//amber color shades
const MaterialColor akAmberColor = Colors.amber;
const MaterialAccentColor akAmberColorAccent = Colors.amberAccent;
const MaterialColor akYellowColor = Colors.yellow;

//orange color shades
const MaterialColor akOrangeColor = Colors.orange;
const MaterialAccentColor akOrangeColorAccent = Colors.orangeAccent;
const MaterialColor akDeepOrangeColor = Colors.deepOrange;

//cyan color shades
const MaterialColor akCyanColor = Colors.cyan;
const MaterialAccentColor akCyanColorAccent = Colors.cyanAccent;

const MaterialColor akPinkColor = Colors.pink;
const MaterialAccentColor akPinkColorAccent = Colors.pinkAccent;

const MaterialColor akPurpleColor = Colors.purple;

//suggested dark theme colors
const Color color0 = Color(0xFF5A5E63);
const Color color1 = Color(0XFF393c3c);
const Color color2 = Color(0XFF505454);
const Color color3 = Color(0XFF48484c);
const Color color4 = Color(0XFF54565c);
const Color color5 = Color(0XFF8c8c8c);
const Color color6 = Color(0XFF7d8484);
const Color color7 = Color(0XFF84858c);
const Color ne = Color(0xFF5A5E63);
const Color color8 = Color(0XFF68696f);
const Color color9 = Color(0XFF242c2c);
const Color color10 = Color(0XFFc5c6cc);
const Color color11 = Color(0XFF27292b);

ThemeData lightTheme = ThemeData(
  brightness: Brightness.light,
  fontFamily: kRoboto,
  primaryColor: akForestWhisper,
  scaffoldBackgroundColor: akPureCanvas,
  primarySwatch: akBlueColor, // Legacy, but kept for compatibility if needed
  colorScheme: ColorScheme.fromSeed(
    seedColor: akForestWhisper,
    primary: akForestWhisper,
    secondary: akSunsetBurst,
    surface: Colors.white,
    background: akPureCanvas,
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: akForestWhisper,
    foregroundColor: Colors.white,
    elevation: 0,
  ),
  useMaterial3: true,
).copyWith();

ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  fontFamily: kRoboto,
  primaryColor: akMintBreeze,
  scaffoldBackgroundColor: akCharcoalShadow,
  canvasColor: akCharcoalShadow,
  primarySwatch: akBlueColor,
  colorScheme: ColorScheme.fromSeed(
    seedColor: akForestWhisper,
    brightness: Brightness.dark,
    primary: akMintBreeze,
    secondary: akElectricLime,
    background: akCharcoalShadow,
    surface: akSageStone,
    onSurface: Colors.white,
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: akCharcoalShadow,
    foregroundColor: Colors.white,
    elevation: 0,
  ),
  useMaterial3: true,
).copyWith();
Color getColorForName(String name) {
  if (name.isNotEmpty) {
    final letter = name.trim().split("").first.toUpperCase();
    return akAlphabetColorMap.keys.toList().contains(letter)
        ? akAlphabetColorMap[letter] ?? akBlackColor
        : akBlackColor;
  } else {
    return akAlphabetColorMap["-"] ?? akBlackColor;
  }
  // Default to black if not found
}

final Map<String, Color?> akAlphabetColorMap = {
  'A': kPrimaryLightColor,
  'B': akBlueColor,
  'C': Colors.green,
  'D': akOrangeColor,
  'E': akPurpleColor,
  'F': akPinkColor,
  'G': Colors.teal,
  'H': akDeepOrangeColor,
  'I': akCyanColor,
  'J': Colors.indigo,
  'K': akPinkColorAccent,
  'L': Colors.brown,
  'M': akDeepOrangeColor,
  'N': Colors.deepPurple,
  'O': Colors.lightBlue,
  'P': Colors.lightGreen,
  'Q': akYellowColor,
  'R': Colors.indigoAccent,
  'S': akBlueColor[300],
  'T': Colors.purpleAccent,
  'U': akOrangeColorAccent,
  'V': Colors.greenAccent,
  'W': Colors.redAccent,
  'X': Colors.tealAccent,
  'Y': akAmberColorAccent,
  'Z': akCyanColorAccent,
  '-': akPinkColorAccent,
};

class NFAlwaysLightTheme extends StatelessWidget {
  final Widget child;
  const NFAlwaysLightTheme({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Theme(data: lightTheme, child: child);
  }
}

//profitability tile BG colors
const Color totalHarvestValueBGColor = Color(0xFFE8F4FF);
const Color totalFarmProfitBGColor = Color(0xFFE8F8EC);
const Color avgProfitPerPondBGColor = Color(0xFFEEF2FF);
const Color avgProfitPerKgBGColor = Color(0xFFFEF3C7);

//profitability tile icon colors
const Color totalHarvestValueColor = kPrimaryLightColor;
const Color totalFarmProfitColor = akAlertGreenColor;
const Color avgProfitPerPondColor = Color(0xFF6366F1);
const Color avgProfitPerKgColor = Color(0xFFF59E0B);
