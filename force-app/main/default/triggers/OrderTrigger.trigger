trigger OrderTrigger on Order (before update, after insert, after delete) {

    if(Trigger.isBefore){
      if(Trigger.isUpdate){
        HandlerClass.updateOrderStatus(trigger.new);
      }
    }
  
    if(Trigger.isAfter){
      if(Trigger.isInsert){
        HandlerClass.activateAccounts(trigger.new);
      }
      
      if(Trigger.isDelete){
        HandlerClass.deactivateAccounts(trigger.old);
      }
    }
  
  }