public without sharing class ContactUpdater {
    
    public static void conUpdate( Contact[] contacts ) {
        List<Contact>cons = new List<Contact>();
   		for ( Contact con : contacts ) {
      		con.firstname = 'Larry';
            cons.add(con);
   		}
        try {
            
            if ( !Schema.sObjectType.Account.fields.name.isUpdateable() ) {
                return;
            } 
            update cons;
        } catch( DMLException e ) {
            System.debug( LoggingLevel.WARN, 'Error = ' + e );
        }
    }
}