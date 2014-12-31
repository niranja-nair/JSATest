/*
* Description - Class to control recursion in MyJSAOpportunityTrigger
*/
public Class MyJSACheckRecursive{

    private static boolean run = true;
    
    public static boolean runOnce(){
        if(run){
            run=false;
            return true;
        }else{
            return run;
        }
    }
}