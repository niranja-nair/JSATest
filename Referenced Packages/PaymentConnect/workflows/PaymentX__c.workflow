<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Send_Payment_Request_Email</fullName>
        <description>Send Payment Request Email</description>
        <protected>false</protected>
        <recipients>
            <field>Contact__c</field>
            <type>contactLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>PaymentConnect/PaymentConnect_Payment_Request</template>
    </alerts>
    <fieldUpdates>
        <fullName>Uncheck_Trigger_Payment_Request</fullName>
        <description>Unchecks the Trigger Payment Request checkbox.</description>
        <field>Trigger_Payment_Request__c</field>
        <literalValue>0</literalValue>
        <name>Uncheck Trigger Payment Request</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>true</protected>
    </fieldUpdates>
    <rules>
        <fullName>Sample Send Payment Request on Trigger</fullName>
        <actions>
            <name>Send_Payment_Request_Email</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>Uncheck_Trigger_Payment_Request</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>PaymentX__c.Amount__c</field>
            <operation>greaterThan</operation>
            <value>0</value>
        </criteriaItems>
        <criteriaItems>
            <field>PaymentX__c.Status__c</field>
            <operation>notEqual</operation>
            <value>Completed</value>
        </criteriaItems>
        <criteriaItems>
            <field>PaymentX__c.Trigger_Payment_Request__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <description>Sends a payment request email when the Trigger Payment Request checkbox is ticked (e.g. by batch payment processing scripts).</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
