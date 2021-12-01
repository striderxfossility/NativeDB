
public static exec func pindatatest(instance: GameInstance) -> Void {
  let mappinData: MappinData;
  let scriptData: ref<TestMappinScriptData> = new TestMappinScriptData();
  scriptData.test = 5;
  mappinData.scriptData = scriptData;
  let otherScriptData: ref<TestMappinScriptData> = mappinData.scriptData as TestMappinScriptData;
  Log("test " + otherScriptData.test);
}
