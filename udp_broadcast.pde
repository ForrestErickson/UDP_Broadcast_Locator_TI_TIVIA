/**
 * udp_broadcast. Created by modifying the Proccessing udp_multicast example.
 *Lee Erickson
 * Date: 20180527
 * Trying to broad cast to a TIVI Launchpad device
 * The TIVA device UDP port apears to be on 23. 
 * The ti file locator.c defines a sequence of four bytes it wants to receive. 
 * These defines are used to describe the device locator protocol.
 #define TAG_CMD                 0xff
 #define TAG_STATUS              0xfe
 #define CMD_DISCOVER_TARGET     0x02
 */

// TAG_CHECK_BYTE formula as per locator.c in LocatorReceive function.
byte TAG_CMD = byte(0xFF);
byte TAG_STATUS = byte(0xFE);
byte CMD_DISCOVER_TARGET = byte(0x02);
byte TAG_CHECK_BYTE = byte((0 - TAG_CMD - 4 - CMD_DISCOVER_TARGET) & 0xff);

// IP addresses and UDP port numbers.
String BROADCAST_IP_ADDRESS = "255.255.255.255";
String MULTICAST_IP_ADDRESS = "224.0.0.1";
String MY_IP_ADDRESS = "192.168.1.29";
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
  
  udp = new UDP( this, UDP_PORT, MULTICAST_IP_ADDRESS );
  udp.loopback(false);  // Suppress our own broadcast.
  udp.log(true);  //This will show the UDP trafic out and into the PC running this software.

//  udp.setReceiveHandler(this.myCustomReceiveHandler);
  udp.setReceiveHandler("myCustomReceiveHandler");

  // Setup listen and wait constantly for incomming data
  udp.listen( true );
  println("We are listening");

  // Turn on broadcast
  udp.broadcast(true);
  // ... well, just verifies if it's really a multicast socket and blablabla
  println( "init as Multicast socket ... " + udp.isMulticast() );
//  println( "init as Broadcast socket ... " + udp.isBroadcast() );
  println( "UDP joins a group  ... "+udp.isJoined() );
//  println( "UDP Broadcast on?  ... " + udp.broadcast(true) );
  println("Click mouse in window to send broadcast and locate devices.");
  
}

// process events
void draw() {
}


/**
 * on mouse click : 
 * send the TI UDP data on mouse click.
 */ 
void mouseClicked() {
  println ("Moused clicked.\n");

 // Tivia Locator UDP string creation.
 // This works with the full Launchpad conditional test   
  byte[] bdata = new byte[4];
  bdata[0] = TAG_CMD;
  bdata[1] = byte(0x04);
  bdata[2] = CMD_DISCOVER_TARGET;
  bdata[3] = byte(TAG_CHECK_BYTE);

  //String sLocator
  String sLocator = str(bdata[0] + bdata[1] + bdata[2] + bdata[3]);
  println( "Sending TI Locator Broadcast. " );
  udp.send( bdata, BROADCAST_IP_ADDRESS, UDP_PORT ); // = send( data, group_ip, port );
} // mouseClicked

 
// Custom receiver handler to get data from the client which responded to the broadcast.
void myCustomReceiveHandler( byte[] data, String ip, int port ) {
  String removeMAC = "";
  String remoteAppTitle = "";
  String remoteIPaddress = ip;
  byte tempdata[] = new byte[255]; 

// Write to the drawing window
  textSize(32);
  text("Got:  ", 0,20);
  for (int i =0; i< data.length ; i++){
    text(hex(data[i]), i*32,41);
    print(hex(data[i]));
  }

//The broadcast to find the Locator is 4 byets so lets ignore them. 
  if (data.length >4) {
  // Write to console. 
    println("\n\nNew Device Located! ");
    println("The device address is: " + ip + " and port: " + port);
    //print("myReceived data: ");
    //println(" ");

    print("Hungry for devices boys and girls? ");

    // Lets parse out some data!
    print("Here is your big mac: ");
    for (int i = 9; i<=14; i++){
       print(hex(data[i]));
    }  
  
    print("\nWhat is your name? (What is your quest?): ");
    //Parse out the "AppTitleSet" locator service field. 
    for (int i = 19; (i<64 && data[i]!=0) ; i++){
       print(char(data[i]));
       tempdata[i-19] = data[i];      

    }// parsing.
//    String str2 = new String(tempdata);
    String str2 = new String(data,19,63);
    println("\nAs a string: " +str2);

  }//If data > 4

} //  myCustomReceiveHandler(byte[] message, String ip, int port) 
 
//End.
