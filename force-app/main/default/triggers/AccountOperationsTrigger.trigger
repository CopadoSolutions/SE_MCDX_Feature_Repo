trigger AccountOperationsTrigger on Account (before insert) {
    for (Account record : Trigger.new) {
        Schema.getGlobalDescribe();
    }
}
