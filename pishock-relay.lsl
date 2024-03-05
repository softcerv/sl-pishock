// Who do you trust enough to let access the collar?
list trusted_list = ["SAMPLE Resident"]; 
// What suffix do we want to use for commands?
string suffix = "SUFFIX_HERE";
// What is your share code?
string share_code = "SAMPLE SHARE CODE";
// What is your API key?
string api_key = "SAMPLE KEY";
// What is your PiShock account username?
string username = "SAMPLE NAME";
// What channel do we want to recieve our shock requests on?
integer recieving_channel = 8;
// Is the relay currently on?
integer relay_on = TRUE;
// Do we want to use a whitelist?
integer use_whitelist = TRUE;

integer send_shock_request(integer type_to_send, integer duration, integer intensity, string name)
{
    if(!relay_on) return FALSE;
    // We don't want invalid requests to be submit.
    if(intensity > 100) return FALSE;
    if(duration > 10) return FALSE;
    if(type_to_send > 2) return FALSE;
    if(type_to_send < 0) return FALSE; 

    llHTTPRequest(
        "https://do.pishock.com/api/apioperate",
        [
            HTTP_METHOD, "POST",
            HTTP_MIMETYPE, "application/json"
        ],
        llList2Json(JSON_OBJECT, [
            "Username", username, 
            "Name", (name + " (" + llGetObjectName() + ")"),
            "Code", share_code,
            "Intensity", intensity,
            "Duration", duration,
            "Apikey", api_key,
            "Op", type_to_send
        ])
    );
    return TRUE;
}

default
{ 
    state_entry()
    {
        llListen(recieving_channel, "", "", "");
    }

    listen(integer channel, string name, key id, string message)
    {
        if(!relay_on) return;
        string recieved_suffix = llList2String(command_list, 3);
        if(recieved_suffix != suffix) return;

        if(use_whitelist){
            integer user_index = llListFindList(trusted_list, [name]);
            if(user_index == -1 )
            {
                llRegionSayTo(id, 0, "You aren't trusted!");            
                return;
            }
        }
        
        list command_list = llParseString2List(message, [" "],[]);
        integer intensity = llList2Integer(command_list, 0);
        integer mode = llList2Integer(command_list, 1);
        integer duration = llList2Integer(command_list, 2);
        send_shock_request(mode, duration, intensity, name);
         
        string owner_name = llKey2Name(llGetOwner());
        string shocker_message = "You used mode " + (string)mode + " on " + owner_name + " at " + (string)intensity + "% intensity for " + (string)duration + " second(s)."; 
        llRegionSayTo(id, 0, shocker_message);    
        
        string shocker_name = llKey2Name(id);
        string shocked_message = shocker_name + " used mode " + (string)mode + " on you at " + (string)intensity + "% intensity for " + (string)duration + " second(s)."; 
        llRegionSayTo(llGetOwner(), 0, shocked_message);
    }

    touch_start(integer total_number)
    {
        relay_on = !relay_on;
        if(relay_on){
            llRegionSayTo(llGetOwner(), 0, "The collar is on!");
            }
        else {
            llRegionSayTo(llGetOwner(), 0, "The collar is off!");      
            }        
    }    
}
