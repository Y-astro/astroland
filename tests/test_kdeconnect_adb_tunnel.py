import unittest
import socket
import threading
import time
import sys
import os

# Import the module under test
sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), "../scripts/phone")))
import kdeconnect_adb_tunnel

class TestKdeConnectAdbTunnel(unittest.TestCase):
    def test_proxy_thread_cleanup(self):
        # 1. Start a mock destination server
        dest_sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        dest_sock.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
        dest_sock.bind(("127.0.0.1", 19740))
        dest_sock.listen(10)
        
        dest_running = True
        def echo_server():
            while dest_running:
                try:
                    conn, _ = dest_sock.accept()
                    def echo(c):
                        try:
                            while True:
                                data = c.recv(1024)
                                if not data:
                                    break
                                c.sendall(data)
                        except Exception:
                            pass
                        finally:
                            try:
                                c.shutdown(socket.SHUT_RDWR)
                            except Exception:
                                pass
                            c.close()
                    threading.Thread(target=echo, args=(conn,), daemon=True).start()
                except Exception:
                    break
        
        t_dest = threading.Thread(target=echo_server, daemon=True)
        t_dest.start()

        # 2. Start TcpProxyServer
        proxy = kdeconnect_adb_tunnel.TcpProxyServer(listen_port=19739, forward_port=19740)
        proxy.start()
        time.sleep(0.1)

        baseline_threads = threading.active_count()

        # 3. Simulate 20 rapid connections and disconnections
        for i in range(20):
            s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
            s.connect(("127.0.0.1", 19739))
            s.sendall(b"hello")
            resp = s.recv(1024)
            self.assertEqual(resp, b"hello")
            # Abrupt disconnect from client side
            s.close()
            time.sleep(0.02)

        # Allow worker threads to settle
        time.sleep(1.0)

        # If threads leaked, active_count will have grown by up to 20-40 threads
        final_threads = threading.active_count()
        diff = final_threads - baseline_threads

        # Clean up
        proxy.stop()
        dest_running = False
        try:
            dest_sock.close()
        except Exception:
            pass

        self.assertLessEqual(diff, 2, f"Leaked {diff} threads after 20 client connections!")

if __name__ == "__main__":
    unittest.main()
