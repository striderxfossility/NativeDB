
public static func TSF_NPC() -> TargetSearchFilter {
  let tsf: TargetSearchFilter = TSF_And(TSF_All(TSFMV.Obj_Puppet | TSFMV.St_Alive), TSF_Not(TSFMV.Obj_Player));
  return tsf;
}

public static func TSF_EnemyNPC() -> TargetSearchFilter {
  let tsf: TargetSearchFilter = TSF_And(TSF_All(TSFMV.Obj_Puppet | TSFMV.Att_Hostile | TSFMV.St_Alive), TSF_Not(TSFMV.Obj_Player));
  return tsf;
}

public static func TSF_NpcOrDevice() -> TargetSearchFilter {
  let tsf: TargetSearchFilter = TSF_And(TSF_Any(TSFMV.Obj_Puppet | TSFMV.Obj_Device | TSFMV.Obj_Sensor), TSF_Not(TSFMV.Obj_Player), TSF_Not(TSFMV.Att_Friendly));
  return tsf;
}

public static func TSF_Quickhackable() -> TargetSearchFilter {
  let tsf: TargetSearchFilter = TSF_And(TSF_All(TSFMV.St_QuickHackable), TSF_Not(TSFMV.Obj_Player), TSF_Not(TSFMV.Att_Friendly), TSF_Any(TSFMV.Sp_Aggressive | TSFMV.Obj_Device));
  return tsf;
}

public static func TSQ_ALL() -> TargetSearchQuery {
  let tsq: TargetSearchQuery;
  return tsq;
}

public static func TSQ_NPC() -> TargetSearchQuery {
  let tsq: TargetSearchQuery;
  tsq.searchFilter = TSF_NPC();
  return tsq;
}

public static func TSQ_EnemyNPC() -> TargetSearchQuery {
  let tsq: TargetSearchQuery;
  tsq.searchFilter = TSF_EnemyNPC();
  return tsq;
}

public static func TSQ_NpcOrDevice() -> TargetSearchQuery {
  let tsq: TargetSearchQuery;
  tsq.searchFilter = TSF_NpcOrDevice();
  return tsq;
}
