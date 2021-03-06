/*
 * Config.h
 *
 *  Created on: 11.11.2016
 *      Author: veske
 */

#ifndef CONFIG_H_
#define CONFIG_H_

#include "Macros.h"
#include <set>

using namespace std;
namespace femocs {

/** Class to initialize and read configuration parameters from configuration file */
class Config {
public:

    /** Constructor initializes configuration parameters */
    Config();

    /** Read the configuration parameters from input script */
    void read_all(const string& file_name, bool full_run=true);

    /** Using the stored path, read the configuration parameters from input script */
    void read_all();

    /** Look up the configuration parameter with string argument */
    int read_command(string param, string& arg);

    /** Look up the configuration parameter with boolean argument */
    int read_command(string param, bool& arg);

    /** Look up the configuration parameter with unsigned integer argument */
    int read_command(string param, unsigned int& arg);

    /** Look up the configuration parameter with integer argument */
    int read_command(string param, int& arg);

    /** Look up the configuration parameter with double argument */
    int read_command(string param, double& arg);

    /** Look up the configuration parameter with several double arguments */
    int read_command(string param, vector<double>& args);

    /** Print the stored commands and parameters */
    void print_data();

    /** Various paths */
    struct Path {
        string extended_atoms;      ///< Path to the file with atoms forming the extended surface
        string infile;              ///< Path to the file with atom coordinates and types
        string mesh_file;           ///< Path to the triangular and tetrahedral mesh data
        string restart_file;        ///< Path to the restart file
    } path;

    /** User specific preferences */
    struct Behaviour {
        string verbosity;           ///< Verbose mode: mute, silent, verbose
        string project;             ///< Type of project to be called; runaway, ...
        int n_restart;              ///< # time steps between writing restart file; 0 disables write
        int restart_multiplier;     ///< After n_write_restart * restart_multiplier time steps, restart file will be copied to separate file
        int n_write_log;            ///< # time steps between writing log file; <0: only last time step, 0: no write, >0: only every n-th
        int n_read_conf;            ///< # time steps between re-reading configuration values from file; 0 turns re-reading off
        int interpolation_rank;     ///< Rank of the solution interpolation; 1-linear tetrahedral, 2-quadratic tetrahedral, 3-linear hexahedral
        double timestep_fs;         ///< Total time evolution within a FEMOCS run call [fs]
        double mass;                ///< Atom mass [amu]
        unsigned int rnd_seed;      ///< Seed for random number generator
        unsigned int n_omp_threads; ///< Number of opened OpenMP threads
        unsigned int timestep_step; ///< Every n_timestep-th timestep is not skipped
    } behaviour;

    /** Enable or disable various support features */
    struct Run {
        bool cluster_anal;          ///< Enable cluster analysis
        bool apex_refiner;          ///< Add elements to the nanotip apex
        bool rdf;                   ///< Re-calculate lattice constant and coordination analysis parameters using radial distribution function
        bool output_cleaner;        ///< Clear output folder before the run
        bool surface_cleaner;       ///< Clean surface by measuring the atom distance from the triangular surface
        bool field_smoother;        ///< Replace nodal field with the average of its neighbouring nodal fields
    } run;

    /** Sizes related to mesh, atoms and simubox */
    struct Geometry {
        string mesh_quality;        ///< Minimum quality (maximum radius-edge ratio) of tetrahedra
        string element_volume;      ///< Maximum volume of tetrahedra
        int nnn;                    ///< Number of nearest neighbours for given crystal structure
        double latconst;            ///< Lattice constant
        double coordination_cutoff; ///< Cut-off distance for coordination analysis [same unit as latconst]
        double cluster_cutoff;      ///< Cut-off distance for cluster analysis [same unit as latconst]; if 0, cluster analysis uses coordination_cutoff instead
        double charge_cutoff;       ///< Cut-off distance for calculating Coulomb forces [same unit as latconst]
        double surface_thickness;   ///< Maximum distance the surface atom is allowed to be from surface mesh [same unit as latconst]; 0 turns check off
        double box_width;           ///< Minimal simulation box width [tip height]
        double box_height;          ///< Simulation box height [tip height]
        double bulk_height;         ///< Bulk substrate height [lattice constant]
        double radius;              ///< Radius of cylinder where surface atoms are not coarsened; 0 enables coarsening of all atoms
        double height;              ///< height of generated artificial nanotip in the units of radius
        /** Minimum rms distance between atoms from current and previous run so that their
         * movement is considered to be sufficiently big to recalculate electric field;
         * 0 turns the check off */
        double distance_tol;
    } geometry;

    /** All kind of tolerances */
    struct Tolerance {
        double charge_min; ///< Min ratio face charges are allowed to deviate from the total charge
        double charge_max; ///< Max ratio face charges are allowed to deviate from the total charge
        double field_min;  ///< Min ratio numerical field can deviate from analytical one
        double field_max;  ///< Max ratio numerical field can deviate from analytical one
    } tolerance;

    /** Parameters for solving field equation */
    struct Field {
        double E0;             ///< Value of long range electric field (Active in case of Neumann anodeBC
        double ssor_param;     ///< Parameter for SSOR preconditioner in DealII
        double cg_tolerance;   ///< Maximum allowed electric potential error
        int n_cg;              ///< Maximum number of Conjugate Gradient iterations in phi calculation
        double V0;             ///< Applied voltage at the anode (active in case of SC emission and Dirichlet anodeBC
        string anode_BC;       ///< Type of anode boundary condition (Dirichlet or Neumann)
        string mode;           ///< Mode to run field solver; laplace
    } field;

    /** Heating module configuration parameters */
    struct Heating {
        string mode;                ///< Method to calculate current density and temperature; none, stationary or transient
        string rhofile;             ///< Path to the file with resistivity table
        double lorentz;             ///< Lorentz number (Wiedemenn-Franz law)
        double t_ambient;           ///< Ambient temperature in heat calculations
        int n_cg;                   ///< Max # Conjugate-Gradient iterations
        double cg_tolerance;        ///< Solution accuracy in Conjugate-Gradient solver
        double ssor_param;          ///< Parameter for SSOR preconditioner in DealII. Its fine tuning optimises calculation time.
        double delta_time;          ///< Timestep of time domain integration [sec]
        double dt_max;              ///< Maximum allowed timestep for heat convergence run
        double tau;                 ///< Time constant in Berendsen thermostat
    } heating;

    /** Field emission module parameters */
    struct Emission {
        double work_function; ///< Work function [eV]
        bool blunt;           ///< Force blunt emitter approximation (good for big systems)
        bool cold;            ///< force cold field emission approximation (good for low temperatures)
        double omega;         ///< Voltage correction factor for SC-limited emission calculation; <= 0 ignores SC
    } emission;

    /** Parameters related to atomic force calculations */
    struct Force {
        string mode;                ///< Forces to be calculated; lorentz, all, none
    } force;

    /** Smooth factors for surface faces, surface atoms and charges */
    struct Smoothing {
        string algorithm;    ///< surface mesh smoother algorithm; none, laplace or fujiwara
        int n_steps;         ///< number of surface mesh smoothing iterations
        double lambda_mesh;  ///< lambda parameter in surface mesh smoother
        double mu_mesh;      ///< mu parameter in surface mesh smoother
        double beta_atoms;   ///< extent of surface smoothing; 0 turns smoothing off
        double beta_charge;  ///< extent of charge smoothing; 0 turns smoothing off
    } smoothing;

    /** Factors that are proportional to the extent of surface coarsening; 0 turns corresponding coarsening component off */
    struct CoarseFactor {
        double amplitude;   ///< coarsening factor outside the warm region
        int r0_cylinder;    ///< minimum distance between atoms in nanotip outside the apex
        int r0_sphere;      ///< minimum distance between atoms in nanotip apex
        double exponential; ///< coarsening rate; min distance between coarsened atoms outside the warm region is d_min ~ pow(|r1-r2|, exponential)
    } cfactor;

private:
    vector<vector<string>> data; ///< commands and their arguments found from the input script
    string file_name;            ///< path to configuration file

    const string comment_symbols = "!#%";
    const string data_symbols = "+-/*_.0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ()";

    /** Check for the obsolete commands from the buffered commands */
    void check_obsolete(const string& file_name);

    /** Check for the obsolete commands that are similar to valid ones */
    void check_changed(const string& command, const string& substitute);

    /** Read the commands and their arguments from the file and store them into the buffer */
    void parse_file(const string& file_name);

    /** Remove the noise from the beginning of the string */
    void trim(string& str);
};

} // namespace femocs

#endif /* CONFIG_H_ */
