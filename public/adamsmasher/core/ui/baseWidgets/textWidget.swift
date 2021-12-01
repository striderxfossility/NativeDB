
public native class inkText extends inkLeafWidget {

  public final native func GetText() -> String;

  public final native func SetText(displayText: String, opt textParams: ref<inkTextParams>) -> Void;

  public final native func SetTextDirect(displayText: String) -> Void;

  public final native func SetLocalizedText(locKey: CName, opt textParams: ref<inkTextParams>) -> Void;

  public final native func SetLocalizedTextString(locKey: String, opt textParams: ref<inkTextParams>) -> Void;

  public final func SetLocalizedTextScript(locKey: String, opt textParams: ref<inkTextParams>) -> Void {
    if IsStringNumber(locKey) {
      this.SetText(locKey, textParams);
    } else {
      if !IsStringValid(locKey) {
        this.SetText("", textParams);
      } else {
        this.SetLocalizedTextString(locKey, textParams);
      };
    };
  }

  public final func SetLocalizedTextScript(locKey: CName, opt textParams: ref<inkTextParams>) -> Void {
    if !IsNameValid(locKey) {
      this.SetText("", textParams);
    } else {
      this.SetLocalizedText(locKey, textParams);
    };
  }

  public final native func GetTextParameters() -> ref<inkTextParams>;

  public final native func SetTextParameters(textParams: ref<inkTextParams>) -> Void;

  public final native func GetLocalizationKey() -> CName;

  public final native func SetLocalizationKey(displayText: CName) -> Void;

  public final native func SetLocalizationKeyString(displayText: String) -> Void;

  public final native func SetTextFromParts(textpart1: String, opt textpart2: String, opt textpart3: String) -> Void;

  public final native func GetVerticalAlignment() -> textVerticalAlignment;

  public final native func SetVerticalAlignment(verticalAlignment: textVerticalAlignment) -> Void;

  public final const func GetVerticalAlignmentEnumValue(nameValue: CName) -> textVerticalAlignment {
    let returnValue: textVerticalAlignment;
    if Equals(nameValue, n"Top") {
      returnValue = textVerticalAlignment.Top;
    } else {
      if Equals(nameValue, n"Bottom") {
        returnValue = textVerticalAlignment.Bottom;
      } else {
        if Equals(nameValue, n"Center") {
          returnValue = textVerticalAlignment.Center;
        };
      };
    };
    return returnValue;
  }

  public final native func GetHorizontalAlignment() -> textHorizontalAlignment;

  public final native func SetHorizontalAlignment(horizontalAlignment: textHorizontalAlignment) -> Void;

  public final const func GetHorizontalAlignmentEnumValue(nameValue: CName) -> textHorizontalAlignment {
    let returnValue: textHorizontalAlignment;
    if Equals(nameValue, n"Left") {
      returnValue = textHorizontalAlignment.Left;
    } else {
      if Equals(nameValue, n"Right") {
        Equals(returnValue, textHorizontalAlignment.Right);
      } else {
        if Equals(nameValue, n"Center") {
          returnValue = textHorizontalAlignment.Center;
        };
      };
    };
    return returnValue;
  }

  public final native func SetFontFamily(fontFamilyPath: String, opt fontStyle: CName) -> Void;

  public final native func GetFontStyle() -> CName;

  public final native func SetFontStyle(fontStyle: CName) -> Void;

  public final native func GetFontSize() -> Int32;

  public final native func SetFontSize(textSize: Int32) -> Void;

  public final native func GetTracking() -> Int32;

  public final native func SetTracking(tracking: Int32) -> Void;

  public final native func GetLetterCase() -> textLetterCase;

  public final native func SetLetterCase(letterCase: textLetterCase) -> Void;

  public final native func EnableAutoScroll(enableState: Bool) -> Void;

  public final native func SetDateTimeByTimestamp(timestamp: Uint64) -> Void;

  public final native func GetScrollTextSpeed() -> Float;

  public final native func SetScrollTextSpeed(scrollTextSpeed: Float) -> Void;
}
