/**
 * udp_broadcast. Created by modifying the Proccessing udp_multicast example.
 * Library at: http://ubaa.net/shared/processing/udp/index.htm
 * This program by Lee Erickson
 * Date: 20180527
 * I hearby release this to the public for any use. It has no warranty. It may kill you but is not guarenteed to do so.
 *
 * I wrote this to work with the locator function in TIVI ware for TI TM4C1294XL Launchpad.
 * Use UDP broad cast to a TIVI Launchpad device and receive by unicast back to my windoes computer.
 * The TIVA device UDP port apears to be on 23. 
 * The ti file locator.c defines a sequence of four bytes it wants to receive. 
 * These defines are used to describe the device locator protocol.
 #define TAG_CMD                 0xff
 #define TAG_STATUS              0xfe
 #define CMD_DISCOVER_TARGET     0x02
 
 * also a second unnamed byte of value 0x40 and a ?check sum? of "(0 - TAG_CMD - 4 - CMD_DISCOVER_TARGET) & 0xff)"
 *
 * This software is a client to request from the Locator server on the TI devices their location information.
 * If you watch with Wireshark set to filer for udp.port==23 you can see the trafic nicly.
 */

// TAG_CHECK_BYTE formula as per locator.c in LocatorReceive function.
byte TAG_CMD = byte(0xFF);
byte TAG_STATUS = byte(0xFE);
byte CMD_DISCOVER_TARGET = byte(0x02);
byte TAG_CHECK_BYTE = byte((0 - TAG_CMD - 4 - CMD_DISCOVER_TARGET) & 0xff);

// IP addresses and UDP port numbers.
String BROADCAST_IP_ADDRESS = "255.255.255.255";
String MULTICAST_IP_ADDRESS = "224.0.0.1";
//String MY_IP_ADDRESS = "192.168.1.29";
int UDP_PORT = 23;

// import UDP library
import hypermedia.net.*;

UDP udp;  // the UDP object

/**
 * init the frame and the UDP object.
 */
 
void setup() {
// Setup Broadcast by setting up multicast????
  size( 255, 255 );
  background( 32 );  // dark gray backround
  // Write to the drawing window
  textSize(24);
  text(" Click to Broadcast", 0,128); 

  
  udp = new UDP( this, UDP_PORT, MULTICAST_IP_ADDRESS );
  udp.loopback(false);  // Suppress our own broadcast.
//  udp.log(true);  //This will show the UDP trafic out and into the PC running this software. Uncomment this to see network trafic.

  // Setup listen and wait constantly for incomming data
  udp.setReceiveHandler("myCustomReceiveHandler");
  udp.listen( true ); 
  println("Broadcast to find devices with the TI TIVA Locator Service.");

  // Turn on broadcast
  udp.broadcast(true);
  println( "init as Multicast socket ... " + udp.isMulticast() );
  println( "UDP joins a group  ... "+udp.isJoined() );
  println("Click mouse in window to send broadcast and locate devices.");
} // setup

// process events
void draw() {
}


/**
 * send the UDP Broadcast data on mouse click.
 */ 
void mouseClicked() {
  println ("Moused clicked.\n");

 // Tivia Locator UDP data sequence creation.
 // This works with the full Ti Launchpad Locator conditional test.   
  byte[] bdata = new byte[4];
  bdata[0] = TAG_CMD;
  bdata[1] = byte(0x04);
  bdata[2] = CMD_DISCOVER_TARGET;
  bdata[3] = byte(TAG_CHECK_BYTE);

  //String sLocator
  String sLocator = str(bdata[0] + bdata[1] + bdata[2] + bdata[3]);
  println( "Sending TI Locator Broadcast." );
  udp.send( bdata, BROADCAST_IP_ADDRESS, UDP_PORT ); // = send( data, group_ip, port );
} // mouseClicked

 
// Custom receiver handler to get data from the client which responded to the broadcast.
void myCustomReceiveHandler( byte[] data, String ip, int port ) {
  String removeMAC = "";
  String remoteAppTitle = "";
  String remoteIPaddress = ip;
  byte tempdata[] = new byte[255]; 

// Write to the drawing window 
  for (int i =0; i< data.length ; i++){
    text(hex(data[i]), i*32,41);  
//    print(hex(data[i]));    // To console too.
  }

//The broadcast to find the Locator is 4 byets so lets ignore them. 
  if (data.length >4) {
  // Write to console. 
    println("\n\nNew Device Located! ");
    println("The device address is: " + ip + " and port: " + port);  //Read out from the address that called the handler.
    
    // Lets parse out some data!
    print("Hungry for devices boys and girls? ");
    print("Here is your big MAC: ");
    int OFFSET_TO_MAC = 9;
    int LENGTH_MAC = 14;
    for (int i = OFFSET_TO_MAC; i<=LENGTH_MAC; i++){
       print(hex(data[i]));
    }  
  
    print("\nWhat is your name? (What is your quest?): ");
    //Parse out the "AppTitleSet" locator service field. 
    int OFFSET_TO_AppTitle = 19;
    int LENGTH_AppTitle = 64;
    
    for (int i = OFFSET_TO_AppTitle; (i<LENGTH_AppTitle && data[i]!=0) ; i++){
       print(char(data[i]));
       tempdata[i-OFFSET_TO_AppTitle] = data[i];      

    }// parsing.
//    Lets make this data into a string.
    String str2 = new String(data,OFFSET_TO_AppTitle,LENGTH_AppTitle-1);
    println("\nAs a string: " +str2);

  }//If data > 4

} //  myCustomReceiveHandler(byte[] message, String ip, int port) 
 
//udp_broadcast end.
