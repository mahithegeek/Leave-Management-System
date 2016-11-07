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

}
