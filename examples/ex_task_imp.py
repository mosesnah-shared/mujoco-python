import sys
import numpy as np
import scipy.io

import mujoco
import mujoco_viewer


sys.path += [ "../controllers", "../modules" ]

from utils         import min_jerk_traj

# Call the xml model file + data for MuJoCo
dir_name   = '../models/my_robots/'
robot_name = '2DOF_planar_torque.xml'
model = mujoco.MjModel.from_xml_path( dir_name + robot_name )
data  = mujoco.MjData( model )

# Create the viewer object
viewer = mujoco_viewer.MujocoViewer( model, data, hide_menus = True )

# Set numpy print options
np.set_printoptions( precision = 4, threshold = 9, suppress = True )

# Parameters for the simulation
T        = 8.                       # Total Simulation Time
dt       = model.opt.timestep       # Time-step for the simulation (set in xml file)
fps      = 30                       # Frames per second
n_frames = 0                        # The current frame of the simulation
speed    = 1.0                      # The speed of the simulator
t_update = 1./fps * speed           # Time for update 
is_save  = False

# The time-step defined in the xml file should be smaller than update
assert( dt <= t_update )

# Set the initial condition of the robot
q1 = 0.2
q_init = np.array( [ q1, np.pi-2*q1 ] )
data.qpos[ 0:2 ] = q_init
mujoco.mj_forward( model, data )

# Define the task-space impedances of the robot 
Kp = 300 * np.eye( 3 )
Bp = 0.2 * Kp

# Get the initial end-effector position
id_ee = model.site( "site_end_effector" ).id
p_init = np.copy( data.site_xpos[ id_ee ] )

# The parameters of the minimum-jerk trajectory.
t0  = 1.0
D1  = 2.0
t02 = t0 + 0.5 * D1
D2  = 1.5
pi   = p_init

del_pf  = np.array( [ -0.7, 0.4, 0.0 ] )
del_pf2 = np.array( [  1.0, 0.5, 0.0 ] )

# Save the references for the q and dq 
q  = data.qpos[ 0:model.nq ]
dq = data.qvel[ 0:model.nq ]

# The necessary data for plotting
q_arr  = [ ]
dq_arr = [ ]

t_arr  = [ ]
p_arr  = [ ]
dp_arr = [ ]

p0_arr  = [ ]
dp0_arr = [ ]

tau_arr = [ ]

Jp = np.zeros( ( 3, model.nq ) )
Jr = np.zeros( ( 3, model.nq ) )

while data.time <= T:

    mujoco.mj_step( model, data )

    # Torque 1: First-order Task-space Impedance Controller
    # Calculate the minimum-jerk trajectory 
    p0  = np.zeros( 3 )
    dp0 = np.zeros( 3 )

    for i in range( 3 ):
        p0[ i ], dp0[ i ], _ = min_jerk_traj( data.time, t0 , t0  + D1, pi[ i ], pi[ i ] +  del_pf[ i ], D1 )
        tmp1, tmp2, _        = min_jerk_traj( data.time, t02, t02 + D2,       0,           del_pf2[ i ], D2 )

        p0[ i ]  += tmp1
        dp0[ i ] += tmp2


    # Get the Jacobian Matrix
    mujoco.mj_jacSite( model, data, Jp, Jr, id_ee )

    p  = np.copy( data.site_xpos[ id_ee ] )
    dp = Jp @ dq

    tau_imp = Jp.T @ ( Kp @ ( p0 - p ) + Bp @ ( dp0 - dp ) )

    # Summing up the torque 
    data.ctrl[ : ] = tau_imp

    # Update Visualization
    if( n_frames != ( data.time // t_update ) ):
        n_frames += 1
        viewer.render( )
        print( "[Time] %6.3f" % data.time )

    if is_save:
        q_arr.append( np.copy( q ) )
        dq_arr.append( np.copy( dq ) )

        p_arr.append( p )
        dp_arr.append( dp )        

        t_arr.append( np.copy( data.time ) )

        p0_arr.append( p0 )
        dp0_arr.append( dp0 )        

        tau_arr.append( tau_imp )


# close
viewer.close()

# If save data, export
if is_save:
    my_dict = { "t_arr" : t_arr, "q_arr" : q_arr, "dq_arr" : dq_arr, "p_arr" : p_arr, "dp_arr" : dp_arr, "tau_arr": tau_arr, 
                "p0_arr" : p0_arr, "dp0_arr":dp0_arr }
    
    scipy.io.savemat( "task_imp.mat", my_dict )
