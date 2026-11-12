#! /usr/bin/env python3
import rostest

from waypoints_test_fixture import PKG, WaypointsTestFixture

NAME = 'waypoints_failing_test'

# Allowed error for the end pose, tighter than the action server can reach
# (it stops within 0.05 m and 2 degrees), so both tests fail
XY_TOLERANCE = 0.001
YAW_TOLERANCE = 0.001


class TestWaypoints(WaypointsTestFixture):

    def test_end_position(self):
        self.check_end_position(XY_TOLERANCE)

    def test_end_yaw(self):
        self.check_end_yaw(YAW_TOLERANCE)


if __name__ == '__main__':
    rostest.rosrun(PKG, NAME, TestWaypoints)
