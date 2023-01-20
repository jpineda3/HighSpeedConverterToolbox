@Library('tfc-lib') _

dockerConfig = getDockerConfig(['MATLAB','Vivado'], matlabHSPro=false)
dockerConfig.add("-e MLRELEASE=R2021b")
dockerHost = 'docker'

////////////////////////////

hdlBranches = ['master','hdl_2021_r1']

stage("Build Toolbox") {
    dockerParallelBuild(hdlBranches, dockerHost, dockerConfig) { 
	branchName ->
	try {
		withEnv(['HDLBRANCH='+branchName]) {
		    checkout scm
	            sh 'git submodule update --init'
		    sh 'make -C ./CI/scripts build'
		    sh 'make -C ./CI/scripts gen_tlbx'
		}
        } catch(Exception ex) {
		if (branchName == 'hdl_2021_r1') {
		    error('Production Toolbox Build Failed')
		}
		else {
		    unstable('Development Build Failed')
		}
        }
        if (branchName == 'hdl_2021_r1') {
	    archiveArtifacts artifacts: '*.mltbx'
            stash includes: '**', name: 'builtSources', useDefaultExcludes: false
        }
    }
}

/////////////////////////////////////////////////////

boardNames = ['daq2','ad9081']
dockerConfig.add("-e HDLBRANCH=hdl_2021_r1")

stage("HDL Tests") {
    dockerParallelBuild(boardNames, dockerHost, dockerConfig) { 
        branchName ->
        withEnv(['BOARD='+branchName]) {
            stage("Source") {
                unstash "builtSources"
                sh 'make -C ./CI/scripts test'
		junit testResults: 'test/*.xml', allowEmptyResults: true
                archiveArtifacts artifacts: 'test/logs/*', followSymlinks: false, allowEmptyArchive: true
            }
            stage("Installer") {
                unstash "builtSources"
                sh 'make -C ./CI/scripts test_installer'
		junit testResults: 'test/*.xml', allowEmptyResults: true
                archiveArtifacts artifacts: 'test/logs/*', followSymlinks: false, allowEmptyArchive: true
            }
        }
    }
}

/////////////////////////////////////////////////////

boardNames = ['daq2', 'NonHW']
dockerConfig.add("-e HDLBRANCH=hdl_2021_r1")

stage("Demo Tests") {
    dockerParallelBuild(boardNames, dockerHost, dockerConfig) { 
        branchName ->
        withEnv(['BOARD='+branchName]) {
            if (branchName == 'daq2') {
                stage("Source") {
                    unstash "builtSources"
                    sh 'make -C ./CI/scripts test_targeting_demos'
            junit testResults: 'test/*.xml', allowEmptyResults: true
                    archiveArtifacts artifacts: 'test/logs/*', followSymlinks: false, allowEmptyArchive: true
                }
            }
            else {
                stage("NonHW") {
                    unstash "builtSources"
                    sh 'make -C ./CI/scripts run_NonHWTests'            
                }            
            }
        }
    }
}




/////////////////////////////////////////////////////

classNames = ['DAQ2']

stage("Hardware Streaming Tests") {
    dockerParallelBuild(classNames, dockerHost, dockerConfig) { 
        branchName ->
        withEnv(['HW='+branchName]) {
            unstash "builtSources"
            sh 'echo ${HW}'
            // sh 'make -C ./CI/scripts test_streaming'
        }
    }
}

//////////////////////////////////////////////////////

node {
    stage('Deploy Development') {
        unstash "builtSources"
        uploadArtifactory('HighSpeedConverterToolbox','*.mltbx')
    }
    if (env.BRANCH_NAME == 'master') {
        stage('Deploy Production') {
            unstash "builtSources"
            uploadFTP('HighSpeedConverterToolbox','*.mltbx')
        }
    }
}

//////////////////////////////////////////////////////
// boardNames = ['daq2','ad9081']
// dockerConfig.add("-e HDLBRANCH=hdl_2019_r2")

// stage("HDL Tests") {
//     dockerParallelBuild(boardNames, dockerHost, dockerConfig) { 
//         branchName ->
//         withEnv(['BOARD='+branchName]) {
//             stage("Synth") {
//                 unstash "builtSources"
//                 sh 'make -C ./CI/scripts test_synth'
//                 junit testResults: 'test/*.xml', allowEmptyResults: true
//                 archiveArtifacts artifacts: 'test/**/*.log', followSymlinks: false, allowEmptyArchive: true
//             }
//         }
//     }
// }
//
