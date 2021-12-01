
public native class InteractionChoiceCaptionScriptPart extends InteractionChoiceCaptionPart {

  protected const func GetPartType() -> gamedataChoiceCaptionPartType {
    return gamedataChoiceCaptionPartType.Invalid;
  }
}

public static func GetCaptionTagsFromArray(argList: script_ref<array<ref<InteractionChoiceCaptionPart>>>) -> String {
  let currType: gamedataChoiceCaptionPartType;
  let postLoc: String;
  let preLoc: String;
  let stringTags: array<String>;
  let toRet: String = "";
  let i: Int32 = 0;
  while i < ArraySize(Deref(argList)) {
    currType = Deref(argList)[i].GetType();
    if Equals(currType, gamedataChoiceCaptionPartType.Tag) {
      preLoc = Deref(argList)[i] as InteractionChoiceCaptionStringPart.content;
      postLoc = GetLocalizedText(preLoc);
      ArrayPush(stringTags, postLoc);
    };
    i = i + 1;
  };
  i = ArraySize(stringTags) - 1;
  while i >= 0 {
    toRet += stringTags[i];
    if i != 0 {
      toRet += " ";
    };
    i = i - 1;
  };
  return toRet;
}
