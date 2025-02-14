object SharedData: TSharedData
  OnCreate = DataModuleCreate
  Height = 438
  Width = 760
  PixelsPerInch = 192
  object mtChatModel: TFDMemTable
    AfterPost = mtChatModelAfterPost
    FieldDefs = <>
    IndexDefs = <>
    FetchOptions.AssignedValues = [evMode]
    FetchOptions.Mode = fmAll
    ResourceOptions.AssignedValues = [rvSilentMode]
    ResourceOptions.SilentMode = True
    UpdateOptions.AssignedValues = [uvCheckRequired, uvAutoCommitUpdates]
    UpdateOptions.CheckRequired = False
    UpdateOptions.AutoCommitUpdates = True
    StoreDefs = True
    Left = 80
    Top = 32
    object mtChatModelid: TStringField
      DisplayWidth = 255
      FieldName = 'id'
      Size = 255
    end
  end
  object mtChatModelProjects: TFDMemTable
    AfterPost = mtChatModelProjectsAfterPost
    OnNewRecord = mtChatModelProjectsNewRecord
    FieldDefs = <>
    IndexDefs = <
      item
        Name = 'by_created_at'
        Fields = 'created_at'
        Options = [ixDescending]
      end>
    IndexFieldNames = 'model_id;created_at:D'
    MasterSource = dsModel
    MasterFields = 'id'
    FetchOptions.AssignedValues = [evMode]
    FetchOptions.Mode = fmAll
    ResourceOptions.AssignedValues = [rvPersistent, rvSilentMode]
    ResourceOptions.Persistent = True
    ResourceOptions.SilentMode = True
    UpdateOptions.AssignedValues = [uvCheckRequired, uvAutoCommitUpdates]
    UpdateOptions.CheckRequired = False
    UpdateOptions.AutoCommitUpdates = True
    StoreDefs = True
    Left = 296
    Top = 32
    object mtChatModelProjectsid: TGuidField
      FieldName = 'id'
      Size = 38
    end
    object mtChatModelProjectsmodel_id: TStringField
      FieldName = 'model_id'
      Size = 255
    end
    object mtChatModelProjectsname: TStringField
      FieldName = 'name'
      Size = 255
    end
    object mtChatModelProjectsdesc: TStringField
      FieldName = 'desc'
      Size = 255
    end
    object mtChatModelProjectsmode: TByteField
      FieldName = 'mode'
    end
    object mtChatModelProjectscreated_at: TDateTimeField
      FieldName = 'created_at'
    end
  end
  object mtProjectChatMessages: TFDMemTable
    AfterPost = mtProjectChatMessagesAfterPost
    OnNewRecord = mtProjectChatMessagesNewRecord
    FieldDefs = <>
    IndexDefs = <>
    IndexFieldNames = 'project_id'
    MasterSource = dsModelProject
    MasterFields = 'id'
    FetchOptions.AssignedValues = [evMode]
    FetchOptions.Mode = fmAll
    ResourceOptions.AssignedValues = [rvSilentMode]
    ResourceOptions.SilentMode = True
    UpdateOptions.AssignedValues = [uvCheckRequired, uvAutoCommitUpdates]
    UpdateOptions.CheckRequired = False
    UpdateOptions.AutoCommitUpdates = True
    StoreDefs = True
    Left = 568
    Top = 32
    object mtProjectChatMessagesid: TGuidField
      FieldName = 'id'
      Size = 38
    end
    object mtProjectChatMessagesproject_id: TGuidField
      FieldName = 'project_id'
      Size = 38
    end
    object mtProjectChatMessagesseq: TIntegerField
      FieldName = 'seq'
    end
    object mtProjectChatMessagesdata: TBlobField
      FieldName = 'data'
    end
    object mtProjectChatMessagesrole: TByteField
      FieldName = 'role'
    end
  end
  object dsModel: TDataSource
    DataSet = mtChatModel
    Left = 72
    Top = 152
  end
  object dsModelProject: TDataSource
    DataSet = mtChatModelProjects
    Left = 240
    Top = 152
  end
  object FDStanStorageJSONLink1: TFDStanStorageJSONLink
    Left = 136
    Top = 312
  end
end
