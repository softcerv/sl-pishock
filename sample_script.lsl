integer mode_to_send = 1;
integer channel_to_send_to = 8;
integer duration = 5;
integer strength = 20;
string prefix_to_use = "SAMPLE";

default
{
    touch_start(integer total_number)
    {
        string shocker_message = (string)strength + " " + (string)mode_to_send + " " + (string)duration + " " + prefix_to_use;
        llRegionSay(channel_to_send_to, shocker_message);    
    }
}
