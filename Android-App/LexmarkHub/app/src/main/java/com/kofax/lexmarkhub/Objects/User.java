package com.kofax.lexmarkhub.Objects;

/**
 * Created by venkateshkarra on 20/10/16.
 */

public class User {

    public  enum Role {
        EMPLOYEE, MANAGER, SUPERVISOR, ADMIN
    }

    private String mFName;
    private String mLName;
    private String mEmpId;
    private String mEmailId;
    private Role mRole;
    private String mSupervisorFName;
    private String mSupervisorLName;
    private String mSupervisorEmail;

    public User(String fName,String lName){
        mFName = fName;
        mLName = lName;
    }

    //Setter methods
    public void setRole(String role){
        switch (role){
            case "employee":
                mRole = Role.EMPLOYEE;
                break;
            //TODO set the remaining roles also
        }
    }

    public void setEmail(String emailId){
        mEmailId = emailId;
    }

    public void setEmpId(String empId){
        mEmpId = empId;
    }

    public void setSupervisorDetails(String fName,String lName,String email){
        mSupervisorEmail = email;
        mSupervisorLName = lName;
        mSupervisorFName = fName;
    }
    //Getter methods
    public String getfName(){
        return mFName;
    }
    public String getlName(){
        return mLName;
    }
    public Role getRole(){
        return mRole;
    }
    public String getEmpId(){
        return mEmpId;
    }
    public String getEmailId() {
        return mEmailId;
    }
    public String getSuperVisorFName(){
        if (mSupervisorFName == null)
            return "";
        return mSupervisorFName;
    }
    public String getSuperVisorLName(){
        if (mSupervisorLName == null)
            return "";
        return mSupervisorLName;
    }
    public String getSuperVisorEmail(){
        if (mSupervisorEmail == null)
            return "";
        return mSupervisorEmail;
    }

}
