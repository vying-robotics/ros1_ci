# Shared test fixture for waypoints_passing_test.py (passing tolerances) and
# waypoints_failing_test.py (tight tolerances)
import math
import unittest

import actionlib
import rospy
from geometry_msgs.msg import Point
from nav_msgs.msg import Odometry
from std_srvs.srv import Empty, EmptyRequest
from tf.transformations import euler_from_quaternion
from tortoisebot_waypoints.msg import WaypointActionAction, WaypointActionGoal

PKG = 'tortoisebot_waypoints'

# Robot spawns at [0, 0]
# Goal sent to action server (odom frame)
GOAL_X = 0.0
GOAL_Y = 0.5

# Give up on goal after timeout (s)
GOAL_TIMEOUT = 60.0


class WaypointsTestFixture(unittest.TestCase):

    def setUp(self):
        rospy.init_node('waypoints_test_node')

        self.odom_sub = rospy.Subscriber('/odom', Odometry, self.odom_callback)
        self.current_position = Point()
        self.current_yaw = 0.0
        self.init_position = Point()
        self.init_yaw = 0.0

        self.service_call_reset()
        self.get_init_position()
        self.action_call()

        # Let the robot settle before reading the end pose
        rospy.sleep(1.0)
        self.final_position = self.current_position
        self.final_yaw = self.current_yaw
        rospy.loginfo("Final position: [%.3f, %.3f], yaw: %.3f",
                      self.final_position.x, self.final_position.y, self.final_yaw)

    def tearDown(self):
        self.odom_sub.unregister()

    def odom_callback(self, msg):
        self.current_position = msg.pose.pose.position
        self.current_yaw = self.quaternion_to_euler(msg.pose.pose.orientation)

    def quaternion_to_euler(self, msg):
        orientation_list = [msg.x, msg.y, msg.z, msg.w]
        (roll, pitch, yaw) = euler_from_quaternion(orientation_list)
        return yaw

    def service_call_reset(self):
        # Start every test from the spawn pose
        rospy.wait_for_service('/gazebo/reset_world', timeout=10)
        s = rospy.ServiceProxy('/gazebo/reset_world', Empty)
        s.call(EmptyRequest())
        rospy.sleep(1.0)

    def get_init_position(self):
        rospy.wait_for_message('/odom', Odometry, timeout=10)
        self.init_position = self.current_position
        self.init_yaw = self.current_yaw
        rospy.loginfo("Initial position: [%.3f, %.3f], yaw: %.3f",
                      self.init_position.x, self.init_position.y, self.init_yaw)

    def action_call(self):
        # Create connection to the action server
        client = actionlib.SimpleActionClient('tortoisebot_as', WaypointActionAction)
        if not client.wait_for_server(rospy.Duration(10)):
            raise RuntimeError("Action server tortoisebot_as is not running")

        # Create goal and send it to the action server
        goal = WaypointActionGoal()
        goal.position.x = GOAL_X
        goal.position.y = GOAL_Y
        rospy.loginfo("Sending goal: [%.3f, %.3f]", GOAL_X, GOAL_Y)
        client.send_goal(goal)

        # Wait for result and cancel goal if it takes too long
        if not client.wait_for_result(rospy.Duration(GOAL_TIMEOUT)):
            rospy.logwarn("Goal not reached within %.0f s, cancelling it", GOAL_TIMEOUT)
            client.cancel_goal()

    def check_end_position(self, xy_tolerance):
        error = math.sqrt(pow(GOAL_X - self.final_position.x, 2) +
                          pow(GOAL_Y - self.final_position.y, 2))
        rospy.loginfo("Position error: %.3f m (tolerance %.3f m)", error, xy_tolerance)
        self.assertTrue(error <= xy_tolerance,
                        "End position [%.3f, %.3f] is not within %.3f m of the goal [%.3f, %.3f]" %
                        (self.final_position.x, self.final_position.y, xy_tolerance,
                         GOAL_X, GOAL_Y))

    def check_end_yaw(self, yaw_tolerance):
        # Robot turns to face goal from its start position,
        # then drives straight to it
        expected_yaw = math.atan2(GOAL_Y - self.init_position.y,
                                  GOAL_X - self.init_position.x)
        error = math.atan2(math.sin(expected_yaw - self.final_yaw),
                           math.cos(expected_yaw - self.final_yaw))
        rospy.loginfo("Yaw error: %.3f rad (tolerance %.3f rad)", error, yaw_tolerance)
        self.assertTrue(math.fabs(error) <= yaw_tolerance,
                        "End yaw %.3f is not within %.3f rad of the expected yaw %.3f" %
                        (self.final_yaw, yaw_tolerance, expected_yaw))
