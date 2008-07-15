/*
 This program is free software; you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation; either version 2 of the License, or
 (at your option) any later version.
 
 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.
 
 You should have received a copy of the GNU General Public License
 along with this program; if not, write to the Free Software
 Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 */

//*****************************************************************
// A text server that listens to a specified port and writes the 
// content of a file when a client connects. Blocks on clients.
// Serves one client at the time.
//
// Nils Hjelte c01nhe@cs.umu.se
//*****************************************************************

#include <stdio.h>
#include <stdlib.h>
#include <limits.h>
#include <pthread.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <assert.h>
#include <netdb.h>
#include <sys/utsname.h>
#include <strings.h>
#include <string.h>
#include <unistd.h>
#include <errno.h>
#include <arpa/inet.h>
#include <sys/time.h>
#include <netinet/tcp.h>
#include <fcntl.h>

#define perror_exit(x) perror(x), exit(-1)
#define SA struct sockaddr
#define BUFSIZE 1024

int create_socket(int port);

/* main */
int main(int argc, char *argv[]) {
	int listen_socket, client_socket, file;
	int port;
	//int stdin_fileno = fileno(stdin);
	char buf[BUFSIZE];
	int bytes_read;
	struct sockaddr_in addr;
	socklen_t addrlen = sizeof(addr);

	if (argc != 3) {
		fprintf(stderr, "Usage: %s <port> <file>\n", *argv);
		fflush(stdout);
		exit(-1);
	}
	
	if ( (port = strtol(argv[1], NULL, 10)) == 0)
		perror_exit("strtol");
	
	if ( (file = open(argv[2], O_RDONLY, 0)) < 0)
		perror_exit("open");
	
	listen_socket = create_socket(port);
	
	while (1) {
		
		/* Wait for client connection */
		if ( (client_socket = accept(listen_socket, (SA *)&addr, &addrlen)) < 0)
			perror_exit("accept");
		
		/* Send file to client */
		while (1) {
			bytes_read = read(file, buf, BUFSIZE-1);
			
			if (bytes_read < 0)
				perror_exit("read");
			
			if (bytes_read == 0)
				break; // EOF
			
			buf[bytes_read] = '\0';
			
			if ( write(client_socket, buf, bytes_read) < 0)
				break;
		}
		
		lseek(file, SEEK_SET, 0);
		close(client_socket);
	}
	
	close(listen_socket);
	close(file);
	return 0;
}

//-------------------------------------------------------------------
// create_socket
// Set up the incoming socket. 
//-------------------------------------------------------------------
int create_socket(int port) {
	struct sockaddr_in addr;
	socklen_t addrlen = sizeof(addr);
	int listen_socket;
	int on = 1;
	
	if ( (listen_socket = socket(PF_INET, SOCK_STREAM, IPPROTO_TCP)) < 0)
        perror_exit("socket");
	
	setsockopt(listen_socket, SOL_SOCKET, SO_REUSEADDR, (void *)&on, sizeof(on));
	setsockopt(listen_socket, SOL_SOCKET, TCP_NODELAY, (void *)&on, sizeof(on));
	
	bzero(&addr, sizeof(addr));
    addr.sin_family = AF_INET;
    addr.sin_port = htons(port);
    addr.sin_addr.s_addr = htonl(INADDR_ANY);
	
	if ( bind(listen_socket, (SA *)&addr, addrlen) < 0)
		perror_exit("bind");

	if ( listen(listen_socket, 1) < 0)
		perror_exit("listen");

	return listen_socket;
}
	