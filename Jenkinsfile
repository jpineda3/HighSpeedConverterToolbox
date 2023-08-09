@Library('tfc-lib') _

flags = gitParseFlags()

dockerConfig = getDockerConfig(['MATLAB','Vivado'], matlabHSPro=false)
dockerConfig.add("-e MLRELEASE=R2022a")
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
		    sh 'pip3 install -r ./CI/gen_doc/requirements_doc.txt'
		    sh 'make -C ./CI/gen_doc doc_ml'
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

boardNames = ['daq2','ad9081','ad9434','ad9739a','ad9265', 'fmcjesdadc1','ad9783','ad9208']
dockerConfig.add("-e HDLBRANCH=hdl_2021_r1")

cstage("HDL Tests", "", flags) {
    dockerParallelBuild(boardNames, dockerHost, dockerConfig) { 
        branchName ->
        withEnv(['BOARD='+branchName]) {
            cstage("Source", branchName, flags) {
                unstash "builtSources"
                sh 'make -C ./CI/scripts test'
		junit testResults: 'test/*.xml', allowEmptyResults: true
                archiveArtifacts artifacts: 'test/logs/*', followSymlinks: false, allowEmptyArchive: true
            }
            cstage("Installer", branchName, flags) {
                unstash "builtSources"
                sh 'make -C ./CI/scripts test_installer'
		junit testResults: 'test/*.xml', allowEmptyResults: true
                archiveArtifacts artifacts: 'test/logs/*', followSymlinks: false, allowEmptyArchive: true
            }
        }
    }
}

/////////////////////////////////////////////////////

boardNames = ['NonHW']

cstage("NonHW Tests", "", flags) {
    dockerParallelBuild(boardNames, dockerHost, dockerConfig) { 
        branchName ->
        withEnv(['BOARD='+branchName]) {
            cstage("NonHW", branchName, flags) {
                unstash "builtSources"
                sh 'make -C ./CI/scripts run_NonHWTests'
            }
        }
    }
}


/////////////////////////////////////////////////////

classNames = ['DAQ2']

cstage("Hardware Streaming Tests", "", flags) {
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
    cstage('Deploy Development', "", flags) {
        unstash "builtSources"
        uploadArtifactory('HighSpeedConverterToolbox','*.mltbx')
    }
    if (env.BRANCH_NAME == 'master') {
        cstage('Deploy Production', "", flags) {
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
