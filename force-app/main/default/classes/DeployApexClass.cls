//this will take a string and turn it into an ApexClass. Use Caution.
public with sharing class DeployApexClass {
    public static void deploy(String classText, String className, String testLevel) {
        usf3.MetadataService.MetadataPort service = new usf3.MetadataService.MetadataPort();
        service.SessionHeader = new usf3.MetadataService.SessionHeader_element();
        service.SessionHeader.sessionId = UserInfo.getSessionId();
        if (String.isEmpty(testLevel))
            testLevel = 'NoTestRun';

        String zippedClass = generateZipfile(classText, className);
        usf3.MetadataService.AsyncResult deployResult= service.deploy(zippedClass, getDeployOptions());

        String jobId = deployResult.id;
        usf3.MetadataService.DeployResult result = service.checkDeployStatus(jobId,true);
        System.debug('deploy status is: ' + className + ' ' + result.status + ' ' + result.stateDetail); 

    }
        

    public static String generateZipfile(String classText, String className) {
            usf3.Zippex sampleZip = new usf3.Zippex();
            Blob fileData = Blob.valueOf(getPackageXml(className));
            sampleZip.addFile('package.xml', fileData, null);
            fileData = Blob.valueOf(getStandardApexClassMetadata());
            sampleZip.addFile('classes/' + className + '.cls-meta.xml', fileData, null);
            fileData = Blob.valueOf(classText);
            sampleZip.addFile('classes/' + className + '.cls', fileData, null);
            return EncodingUtil.base64Encode(sampleZip.getZipArchive());

        }
    public static usf3.MetadataService.DeployOptions getDeployOptions(){
             
        usf3.MetadataService.DeployOptions lvDeployOption = new usf3.MetadataService.DeployOptions();
        lvDeployOption.allowMissingFiles = false;
        lvDeployOption.autoUpdatePackage = true;
        lvDeployOption.checkOnly = false;
        lvDeployOption.ignoreWarnings = true;
        lvDeployOption.performRetrieve = false;
        lvDeployOption.purgeOnDelete = false;
        lvDeployOption.rollbackOnError = true;
        lvDeployOption.runTests = new String[]{};
        lvDeployOption.singlePackage = true;
        lvDeployOption.testLevel = 'NoTestRun';
           
         
        return lvDeployOption;
        }


        public static String getPackageXml(String className)
        {
            return '<?xml version="1.0" encoding="UTF-8"?>' + 
                '<Package xmlns="http://soap.sforce.com/2006/04/metadata">' + 
                    '<types>' + 
                        '<members>' + className + '</members>' +
                        '<name>ApexClass</name>' + 
                    '</types>' + 
                    '<version>48.0</version>' + 
                '</Package>';		
        }
    
        public static String getStandardApexClassMetadata()
        {
            return '<?xml version="1.0" encoding="UTF-8"?>' +
                '<ApexClass xmlns="http://soap.sforce.com/2006/04/metadata">' +
                    '<apiVersion>48.0</apiVersion>' + 
                    '<status>Active</status>' +
                '</ApexClass>';		
        }

        
            

}
