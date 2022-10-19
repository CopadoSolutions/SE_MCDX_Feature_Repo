public without sharing class ContactUpdater {
    
    public static void conUpdate( Contact[] cons ) {
        List<Contact>contacts = new List<Contact>();
   		for ( Contact con : cons ) {
      		con.firstname = 'Jones';
            contacts.add(con);
   		}
        try {
            
            if ( !Schema.sObjectType.Account.fields.name.isUpdateable() ) {
                return;
            } 
            update contacts;
        } catch( DMLException e ) {
            System.debug( LoggingLevel.WARN, 'Error = ' + e );
        }
    }
}